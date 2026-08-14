----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 01:36:27 AM
-- Design Name: 
-- Module Name: UART_RX_tb - Behavioral
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

entity UART_RX_tb is
--  Port ( );
end UART_RX_tb;

architecture Behavioral of UART_RX_tb is

----------------------------------------------------
-- PARAMETERS
----------------------------------------------------
constant CLK_PERIOD   : time := 10 ns;
constant CLKS_PER_BIT : integer := 868;

----------------------------------------------------
-- SIGNALS
----------------------------------------------------
signal clk       : std_logic := '0';
signal rst       : std_logic := '0';

signal rx_serial : std_logic := '1';

signal rx_data   : std_logic_vector(7 downto 0);
signal rx_done   : std_logic;

signal frame_count : integer := 0;

----------------------------------------------------
-- TASK: SEND UART BYTE
----------------------------------------------------
procedure send_uart_byte (
    signal rx : out std_logic;
    data      : in  std_logic_vector(7 downto 0)
) is
begin

    -- START BIT
    rx <= '0';
    wait for CLKS_PER_BIT * CLK_PERIOD;

    -- DATA BITS (LSB first)
    for i in 0 to 7 loop
        rx <= data(i);
        wait for CLKS_PER_BIT * CLK_PERIOD;
    end loop;

    -- STOP BIT
    rx <= '1';
    wait for CLKS_PER_BIT * CLK_PERIOD;

end procedure;

begin

----------------------------------------------------
-- CLOCK
----------------------------------------------------

clk_process : process
begin
    --while true loop
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    --end loop;
end process;


----------------------------------------------------
-- DUT
----------------------------------------------------
dut : entity work.UART_RX
generic map(
    CLKS_PER_BIT => CLKS_PER_BIT
)
port map(
    clk       => clk,
    rst       => rst,
    rx_serial => rx_serial,
    rx_data   => rx_data,
    rx_done   => rx_done
);




----------------------------------------------------
-- STIMULUS
----------------------------------------------------
stimulus : process
begin

    ------------------------------------------------
    -- RESET
    ------------------------------------------------
    rst <= '1';
    wait for 100 ns;
    rst <= '0';

    wait for 200 ns;

------------------------------------------------
    -- FRAME 1
    ------------------------------------------------
    send_uart_byte(rx_serial, x"A5");

    wait until rx_done = '1';
    assert rx_data = x"A5"
        report "ERROR: RX mismatch A5"
        severity error;

    frame_count <= frame_count + 1;

    ------------------------------------------------
    -- FRAME 2
    ------------------------------------------------
    wait for 2 us;

    send_uart_byte(rx_serial, x"3C");

    wait until rx_done = '1';
    assert rx_data = x"3C"
        report "ERROR: RX mismatch 3C"
        severity error;

    frame_count <= frame_count + 1;
 ------------------------------------------------
    -- BACK-TO-BACK FRAMES
    ------------------------------------------------
    wait for 2 us;

    send_uart_byte(rx_serial, x"AA");
    send_uart_byte(rx_serial, x"55");

    ------------------------------------------------
    -- RESET DURING FRAME
    ------------------------------------------------
    wait for 5 us;

    send_uart_byte(rx_serial, x"F0");

    wait for 3 us;

    rst <= '1';
    wait for 100 ns;
    rst <= '0';

    ------------------------------------------------
    -- END SIMULATION
    ------------------------------------------------
           wait for 20 ns;
    report "Simulation completed successfully" severity note;
    std.env.stop;
end process;

end Behavioral;
