----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 04:54:05 AM
-- Design Name: 
-- Module Name: g_filter_meta - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity g_filter_meta is
    Generic (
        DATA_WIDTH  : integer := 8;
        IMAGE_WIDTH : integer := 640
    );
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        pixel_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_in    : in  std_logic;

        pixel_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_out   : out std_logic
        );end g_filter_meta;


architecture Behavioral of g_filter_meta is

 type line_buffer_type is array (0 to IMAGE_WIDTH-1) of unsigned(DATA_WIDTH-1 downto 0);

    signal lb0, lb1 : line_buffer_type := (others => (others => '0'));

    signal col : integer range 0 to IMAGE_WIDTH-1 := 0;
    signal row : integer := 0;

    -- Window registers
    signal w00,w01,w02 : unsigned(DATA_WIDTH-1 downto 0) := (others=>'0');
    signal w10,w11,w12 : unsigned(DATA_WIDTH-1 downto 0) := (others=>'0');
    signal w20,w21,w22 : unsigned(DATA_WIDTH-1 downto 0) := (others=>'0');

    signal v1,v2,v3 : std_logic := '0';

    constant ACC_WIDTH : integer := DATA_WIDTH + 8;

    signal acc : unsigned(ACC_WIDTH-1 downto 0);
    signal result : unsigned(DATA_WIDTH-1 downto 0);

begin

process(clk)
    variable lb0_old, lb1_old : unsigned(DATA_WIDTH-1 downto 0);
begin

            v1 <= '0';

            if valid_in='1' then

                -- 🔥 READ OLD BUFFER VALUES FIRST
                lb0_old := lb0(col);
                lb1_old := lb1(col);

                ------------------------------------------------
                -- SHIFT WINDOW (CORRECT ORDER)
                ------------------------------------------------
                w00 <= w01;
                w01 <= w02;
                w02 <= unsigned(pixel_in);

                w10 <= w11;
                w11 <= w12;
                w12 <= lb0_old;

                w20 <= w21;
                w21 <= w22;
                w22 <= lb1_old;

                ------------------------------------------------
                -- UPDATE LINE BUFFERS AFTER READ
                ------------------------------------------------
                lb1(col) <= lb0_old;
                lb0(col) <= unsigned(pixel_in);

                ------------------------------------------------
                -- COUNTERS
                ------------------------------------------------
                if col = IMAGE_WIDTH-1 then
                    col <= 0;
                    row <= row + 1;
                else
                    col <= col + 1;
                end if;

                if row >= 2 and col >= 2 then
                    v1 <= '1';
                end if;
            end if;

            ------------------------------------------------
            -- STAGE 1+2 (COMBINED)
            ------------------------------------------------
if v1='1' then
    acc <= 
        resize(w00, ACC_WIDTH) +

        (resize(w01, ACC_WIDTH) sll 1) +
        resize(w02, ACC_WIDTH) +

        (resize(w10, ACC_WIDTH) sll 1) +
        (resize(w11, ACC_WIDTH) sll 2) +
        (resize(w12, ACC_WIDTH) sll 1) +

        resize(w20, ACC_WIDTH) +
        (resize(w21, ACC_WIDTH) sll 1) +
        resize(w22, ACC_WIDTH);
end if;

            v2 <= v1;
            v3 <= v2;

            ------------------------------------------------
            -- FINAL
            ------------------------------------------------
            if v3='1' then
                result <= acc(DATA_WIDTH+3 downto 4);
            end if;

     
    
end process;

pixel_out <= std_logic_vector(result);
valid_out <= v3;



end Behavioral;
