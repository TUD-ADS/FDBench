----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 01:10:17 AM
-- Design Name: 
-- Module Name: UART_TX - Behavioral
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

entity UART_TX_wfsm is
generic (
    CLKS_PER_BIT : integer := 868
);
port (
    clk       : in  std_logic;
    rst       : in  std_logic;

    tx_start  : in  std_logic;
    tx_data   : in  std_logic_vector(7 downto 0);

    tx_serial : out std_logic;
    tx_busy   : out std_logic;
    tx_done   : out std_logic
);
end UART_TX_wfsm;

architecture rtl of UART_TX_wfsm is

type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT, CLEANUP);

signal state_reg, state_next : state_type := IDLE;

signal clk_count_reg, clk_count_next : integer range 0 to CLKS_PER_BIT-1 := 0;
signal bit_index_reg, bit_index_next : integer range 0 to 7 := 0;

signal data_reg, data_next : std_logic_vector(7 downto 0) := (others=>'0');

signal tx_reg, tx_next : std_logic := '1';

signal tx_busy_reg, tx_busy_next : std_logic := '0';
signal tx_done_reg, tx_done_next : std_logic := '0';

begin

tx_serial <= tx_reg;
tx_busy   <= tx_busy_reg;
tx_done   <= tx_done_reg;

-------------------------------------------------
-- Sequential process
-------------------------------------------------

process(clk)
begin
    if rising_edge(clk) then

        if rst='1' then

            state_reg     <= IDLE;
            clk_count_reg <= 0;
            bit_index_reg <= 0;
            data_reg      <= (others=>'0');

            tx_reg        <= '1';
            tx_busy_reg   <= '0';
            tx_done_reg   <= '0';

        else

            state_reg     <= state_next;
            clk_count_reg <= clk_count_next;
            bit_index_reg <= bit_index_next;
            data_reg      <= data_next;

            tx_reg        <= tx_next;
            tx_busy_reg   <= tx_busy_next;
            tx_done_reg   <= tx_done_next;

        end if;

    end if;
end process;

-------------------------------------------------
-- Combinational next state logic
-------------------------------------------------

process(state_reg, clk_count_reg, bit_index_reg, tx_start, tx_data, data_reg)
begin

-- defaults

state_next      <= state_reg;
clk_count_next  <= clk_count_reg;
bit_index_next  <= bit_index_reg;
data_next       <= data_reg;

tx_next         <= tx_reg;
tx_busy_next    <= '1';
tx_done_next    <= '0';

case state_reg is

when IDLE =>

    tx_next <= '1';
    tx_busy_next <= '0';

    if tx_start='1' then
        data_next <= tx_data;
        state_next <= STOP_BIT;
        clk_count_next <= 0;
    end if;

when START_BIT =>

    tx_next <= '0';

    if clk_count_reg < CLKS_PER_BIT-1 then
        clk_count_next <= clk_count_reg + 1;
    else
        clk_count_next <= 0;
        state_next <= DATA_BITS;
    end if;

when DATA_BITS =>

    tx_next <= data_reg(bit_index_reg);

    if clk_count_reg < CLKS_PER_BIT-1 then
        clk_count_next <= clk_count_reg + 1;
    else

        clk_count_next <= 0;

        if bit_index_reg < 7 then
            bit_index_next <= bit_index_reg + 1;
        else
            bit_index_next <= 0;
            state_next <= CLEANUP;
        end if;

    end if;

when STOP_BIT =>

    tx_next <= '1';

    if clk_count_reg < CLKS_PER_BIT-1 then
        clk_count_next <= clk_count_reg + 1;
    else
        clk_count_next <= 0;
        state_next <= CLEANUP;
    end if;

when CLEANUP =>

    tx_done_next <= '1';
    tx_busy_next <= '0';
    state_next <= IDLE;

end case;

end process;

end rtl;