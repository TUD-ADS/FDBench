----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 02:22:48 AM
-- Design Name: 
-- Module Name: fsm_uart_tb - Behavioral
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

entity fsm_uart_tb is
end fsm_uart_tb;

architecture Behavioral of fsm_uart_tb is

signal clk      : std_logic := '0';
signal reset    : std_logic := '1';

constant clk_period : time := 10 ns;
constant BAUD_DIV   : integer := 16;

signal tx_start : std_logic := '0';
signal tx_data  : std_logic_vector(7 downto 0);

signal tx_m     : std_logic;
signal busy_m   : std_logic;

-- ? NO MULTIPLE DRIVER ISSUE
signal rx_wire  : std_logic;
signal rx       : std_logic;

signal rx_data  : std_logic_vector(7 downto 0);
signal rx_done  : std_logic;

begin

----------------------------------------------------------------
-- DUT
----------------------------------------------------------------
dut: entity work.fsm_uart
port map (
    baud_clk => clk,
    reset    => reset,
    tx_start => tx_start,
    tx_data  => tx_data,
    tx_busy  => busy_m,
    tx       => tx_m,
    rx       => rx,
    rx_data  => rx_data,
    rx_done  => rx_done
);

-- SAFE LOOPBACK
rx_wire <= tx_m;
rx <= rx_wire;

-- CLOCK

clk_process : process
begin
    while true loop
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end loop;
end process;
-- STIMULUS + ASSERTIONS

stim : process
    variable expected : std_logic_vector(7 downto 0);
begin

    wait for 50 ns;
    reset <= '0';

 -- TEST 1

    expected := x"A5";
    tx_data  <= expected;

    tx_start <= '1';
    wait for clk_period;
    tx_start <= '0';

    wait for BAUD_DIV * 12 * clk_period;

    assert rx_done = '1' report "RX not done (T1)" severity note;
    assert rx_data = expected report "Mismatch (T1)" severity note;

   -- TEST 2

    expected := x"FF";
    tx_data  <= expected;

    tx_start <= '1';
    wait for clk_period;
    tx_start <= '0';

    wait for BAUD_DIV * 12 * clk_period;

    assert rx_data = expected report "Mismatch (T2)" severity note;

   -- TEST 3
    expected := x"3C";
    tx_data  <= expected;

    tx_start <= '1';
    wait for clk_period;
    tx_start <= '0';

    wait for BAUD_DIV * 12 * clk_period;

    assert rx_data = expected report "Mismatch (T3)" severity error;


    report "ALL TESTS PASSED ?" severity note;

    wait for 20 ns;
    report "Simulation Finished";
    std.env.stop;

end process;

end Behavioral;