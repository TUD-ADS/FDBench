----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 01:36:07 AM
-- Design Name: 
-- Module Name: UART_RX - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_RX is
generic (
    CLKS_PER_BIT : integer := 868
);
port (
    clk       : in  std_logic;
    rst       : in  std_logic;

    rx_serial : in  std_logic;

    rx_data   : out std_logic_vector(7 downto 0);
    rx_done   : out std_logic
);end UART_RX;

architecture Behavioral of UART_RX is

type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT, CLEANUP);

signal state_reg, state_next : state_type := IDLE;

signal clk_count_reg, clk_count_next : integer range 0 to CLKS_PER_BIT-1 := 0;
signal bit_index_reg, bit_index_next : integer range 0 to 7 := 0;

signal data_reg, data_next : std_logic_vector(7 downto 0) := (others=>'0');

signal rx_done_reg, rx_done_next : std_logic := '0';

-- Synchronizer (important for real hardware)
signal rx_sync_0, rx_sync_1 : std_logic := '1';

begin

rx_data <= data_reg;
rx_done <= rx_done_reg;

-------------------------------------------------
-- Synchronizer (metastability protection)
-------------------------------------------------
process(clk)
begin
    if rising_edge(clk) then
        rx_sync_0 <= rx_serial;
        rx_sync_1 <= rx_sync_0;
    end if;
end process;


-------------------------------------------------
-- Sequential process
-------------------------------------------------
process(clk,rst)
begin
    if rising_edge(clk) then

        if rst='1' then
            state_reg     <= IDLE;
            clk_count_reg <= 0;
            bit_index_reg <= 0;
            data_reg      <= (others=>'0');
            rx_done_reg   <= '0';

        else
            state_reg     <= state_next;
            clk_count_reg <= clk_count_next;
            bit_index_reg <= bit_index_next;
            data_reg      <= data_next;
            rx_done_reg   <= rx_done_next;
        end if;

    end if;
end process;


-------------------------------------------------
-- Combinational next state logic
-------------------------------------------------
process(state_reg, clk_count_reg, bit_index_reg, rx_sync_1, data_reg)
begin

-- defaults
state_next      <= state_reg;
clk_count_next  <= clk_count_reg;
bit_index_next  <= bit_index_reg;
data_next       <= data_reg;
rx_done_next    <= '0';

case state_reg is

-------------------------------------------------
when IDLE =>

    clk_count_next <= 0;
    bit_index_next <= 0;

    if rx_sync_1 = '0' then  -- start bit detected
        state_next <= START_BIT;
    end if;


-------------------------------------------------
when START_BIT =>

    -- wait half bit to sample center
    if clk_count_reg = (CLKS_PER_BIT-1)/2 then
        if rx_sync_1 = '0' then
            clk_count_next <= 0;
            state_next <= DATA_BITS;
        else
            state_next <= IDLE; -- false start
        end if;
    else
        clk_count_next <= clk_count_reg + 1;
    end if;

-------------------------------------------------
when DATA_BITS =>

    if clk_count_reg < CLKS_PER_BIT-1 then
        clk_count_next <= clk_count_reg + 1;
    else
        clk_count_next <= 0;

        data_next(bit_index_reg) <= rx_sync_1;

        if bit_index_reg < 7 then
            bit_index_next <= bit_index_reg + 1;
        else
            bit_index_next <= 0;
            state_next <= STOP_BIT;
        end if;
    end if;


-------------------------------------------------
when STOP_BIT =>

    if clk_count_reg < CLKS_PER_BIT-1 then
        clk_count_next <= clk_count_reg + 1;
    else
        clk_count_next <= 0;
        state_next <= CLEANUP;
    end if;

-------------------------------------------------
when CLEANUP =>

    rx_done_next <= '1';
    state_next   <= IDLE;

-------------------------------------------------
when others =>
    state_next <= IDLE;

end case;

end process;

end Behavioral;
