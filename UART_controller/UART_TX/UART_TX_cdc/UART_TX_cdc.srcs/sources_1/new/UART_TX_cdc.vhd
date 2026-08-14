----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 03:29:32 AM
-- Design Name: 
-- Module Name: UART_TX_cdc - Behavioral
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

----------------------------------------------------------------------------------
-- UART_TX CDC Bug Version
-- Intentionally introduces clock domain crossing issue
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX_cdc is
generic (
    CLKS_PER_BIT : integer := 868
);
port (
    clk       : in  std_logic;
    clk1       : in  std_logic;
    rst       : in  std_logic;

    tx_start  : in  std_logic;
    tx_data   : in  std_logic_vector(7 downto 0);

    tx_serial : out std_logic;
    tx_busy   : out std_logic;
    tx_done   : out std_logic
);
end UART_TX_cdc;

architecture rtl of UART_TX_cdc is

-------------------------------------------------
-- FSM
-------------------------------------------------

type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT, CLEANUP);

signal state : state_type := IDLE;

-------------------------------------------------
-- UART registers
-------------------------------------------------

signal clk_count : integer range 0 to CLKS_PER_BIT-1 := 0;
signal bit_index : integer range 0 to 7 := 0;

signal data_reg : std_logic_vector(7 downto 0) := (others=>'0');

signal tx_reg : std_logic := '1';

-------------------------------------------------
-- CDC Bug Signals
-------------------------------------------------

signal async_clk : std_logic := '0';
signal start_async : std_logic := '0';

-------------------------------------------------
-- Clock divider (creates asynchronous domain)
-------------------------------------------------

signal div_cnt : integer range 0 to 50 := 0;

begin

-------------------------------------------------
-- Output
-------------------------------------------------

tx_serial <= tx_reg;

-------------------------------------------------
-- Create asynchronous clock (CDC bug source)
-------------------------------------------------

process(clk)
begin
    if rising_edge(clk) then

        if div_cnt < 25 then
            div_cnt <= div_cnt + 1;
        else
            div_cnt <= 0;
            async_clk <= not async_clk;  -- new clock domain
        end if;

    end if;
end process;

-------------------------------------------------
-- CDC BUG
-- Sampling tx_start in async clock domain
-------------------------------------------------

process(clk1)
begin
    if rising_edge(clk1) then

        if tx_start='1' then
            start_async <= '1';
        else
            start_async <= '0';
        end if;

    end if;
end process;

-------------------------------------------------
-- UART TX FSM (main clock domain)
-------------------------------------------------

process(clk)
begin
    if rising_edge(clk) then

        if rst='1' then

            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            tx_reg <= '1';
            tx_busy <= '0';
            tx_done <= '0';

        else

            case state is

            -------------------------------------------------
            when IDLE =>

                tx_busy <= '0';
                tx_done <= '0';
                tx_reg  <= '1';

                -- BUG: start signal from async clock domain
                if start_async='1' then
                    data_reg <= tx_data;
                    state <= START_BIT;
                    tx_busy <= '1';
                end if;

            -------------------------------------------------
            when START_BIT =>

                tx_reg <= '0';

                if clk_count < CLKS_PER_BIT-1 then
                    clk_count <= clk_count + 1;
                else
                    clk_count <= 0;
                    state <= DATA_BITS;
                end if;

            -------------------------------------------------
            when DATA_BITS =>

                tx_reg <= data_reg(bit_index);

                if clk_count < CLKS_PER_BIT-1 then
                    clk_count <= clk_count + 1;

                else

                    clk_count <= 0;

                    if bit_index < 7 then
                        bit_index <= bit_index + 1;
                    else
                        bit_index <= 0;
                        state <= STOP_BIT;
                    end if;

                end if;

            -------------------------------------------------
            when STOP_BIT =>

                tx_reg <= '1';

                if clk_count < CLKS_PER_BIT-1 then
                    clk_count <= clk_count + 1;
                else
                    clk_count <= 0;
                    state <= CLEANUP;
                end if;

            -------------------------------------------------
            when CLEANUP =>

                tx_done <= '1';
                tx_busy <= '0';
                state <= IDLE;

            end case;

        end if;

    end if;
end process;

end rtl;