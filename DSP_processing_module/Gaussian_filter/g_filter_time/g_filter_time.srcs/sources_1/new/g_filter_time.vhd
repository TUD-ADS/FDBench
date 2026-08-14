----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 04:56:31 AM
-- Design Name: 
-- Module Name: g_filter_time - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity g_filter_time is
    Generic (
        DATA_WIDTH : integer := 8;
        IMAGE_WIDTH : integer := 640
    );
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        pixel_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_in    : in  std_logic;
        pixel_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_out   : out std_logic
    );
end g_filter_time;

architecture timing_bug of g_filter_time is

------------------------------------------------------------
-- LINE BUFFER
------------------------------------------------------------
type line_buffer_type is array (0 to IMAGE_WIDTH-1)
    of unsigned(DATA_WIDTH-1 downto 0);

signal line_buffer_0 : line_buffer_type := (others => (others => '0'));
signal line_buffer_1 : line_buffer_type := (others => (others => '0'));

------------------------------------------------------------
-- COUNTERS
------------------------------------------------------------
signal col_count : integer range 0 to IMAGE_WIDTH-1 := 0;
signal row_count : integer range 0 to 1023 := 0;

------------------------------------------------------------
-- 3x3 WINDOW
------------------------------------------------------------
signal w00, w01, w02 : unsigned(DATA_WIDTH-1 downto 0) := (others=>'0');
signal w10, w11, w12 : unsigned(DATA_WIDTH-1 downto 0) := (others=>'0');
signal w20, w21, w22 : unsigned(DATA_WIDTH-1 downto 0) := (others=>'0');

------------------------------------------------------------
-- RESULT
------------------------------------------------------------
signal result : unsigned(DATA_WIDTH-1 downto 0) := (others=>'0');

------------------------------------------------------------
-- COEFFICIENTS
------------------------------------------------------------
constant C1 : integer := 1;
constant C2 : integer := 2;
constant C4 : integer := 4;

begin

process(clk)
    variable acc : unsigned(DATA_WIDTH+10 downto 0); -- large accumulator
begin
    if rising_edge(clk) then

        if rst = '1' then
            col_count <= 0;
            row_count <= 0;
            result    <= (others=>'0');
            valid_out <= '0';

        else

            valid_out <= '0';

            if valid_in = '1' then

                ------------------------------------------------
                -- WINDOW UPDATE
                ------------------------------------------------
                w00 <= w01;
                w01 <= w02;
                w02 <= unsigned(pixel_in);

                w10 <= w11;
                w11 <= w12;
                w12 <= line_buffer_0(col_count);

                w20 <= w21;
                w21 <= w22;
                w22 <= line_buffer_1(col_count);

                line_buffer_0(col_count) <= unsigned(pixel_in);
                line_buffer_1(col_count) <= line_buffer_0(col_count);

                ------------------------------------------------
                -- COUNTERS
                ------------------------------------------------
                if col_count = IMAGE_WIDTH-1 then
                    col_count <= 0;
                    row_count <= row_count + 1;
                else
                    col_count <= col_count + 1;
                end if;

                ------------------------------------------------
                -- ? TIMING BUG: FULL GAUSSIAN IN ONE CYCLE
                ------------------------------------------------
                if row_count >= 2 and col_count >= 2 then

                    acc := (others=>'0');

                    -- 9 MULTIPLIERS + ADD TREE (LONG PATH)
acc := (others=>'0');

acc := acc +
    resize(w00 * to_unsigned(C1, DATA_WIDTH), acc'length) +
    resize(w01 * to_unsigned(C2, DATA_WIDTH), acc'length) +
    resize(w02 * to_unsigned(C1, DATA_WIDTH), acc'length) +

    resize(w10 * to_unsigned(C2, DATA_WIDTH), acc'length) +
    resize(w11 * to_unsigned(C4, DATA_WIDTH), acc'length) +
    resize(w12 * to_unsigned(C2, DATA_WIDTH), acc'length) +

    resize(w20 * to_unsigned(C1, DATA_WIDTH), acc'length) +
    resize(w21 * to_unsigned(C2, DATA_WIDTH), acc'length) +
    resize(w22 * to_unsigned(C1, DATA_WIDTH), acc'length);

-- FIXED NORMALIZATION
result <= resize(acc(acc'high downto 4), DATA_WIDTH);

                    valid_out <= '1';
                end if;

            end if;
        end if;
    end if;
end process;

pixel_out <= std_logic_vector(result);

end timing_bug;