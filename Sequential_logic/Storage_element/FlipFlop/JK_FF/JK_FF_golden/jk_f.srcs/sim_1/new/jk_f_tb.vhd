----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2025 10:31:52 PM
-- Design Name: 
-- Module Name: jk_f_tb - Behavioral
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
-- Company:
-- Engineer:
--
-- Create Date:
-- Design Name:
-- Module Name: jk_tb
-- Description:
-- Testbench for JK Flip-Flop bug injection experiments
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity jk_f_tb is
end jk_f_tb;

architecture Behavioral of jk_f_tb is

-- CLOCKS AND RESET

signal clk  : std_logic := '0';
signal clk2 : std_logic := '0';
signal rst  : std_logic := '1';

constant clk_period  : time := 10 ns;
constant clk_period2 : time := 14 ns;

-- INPUT SIGNALS


signal J : std_logic := '0';
signal K : std_logic := '0';

-- OUTPUTS

signal Q_golden : std_logic;
signal Qbar_golden : std_logic;

-- BUG STATISTICS

signal injected_bugs : integer := 0;
signal detected_bugs : integer := 0;

begin

-- DUT INSTANTIATIONS

GOLDEN : entity work.jk_f
port map(
    clock => clk,
    J => J,
    K => K,
    reset => rst,
    Q => Q_golden,
    Qbar => Qbar_golden
);

-- CLOCK GENERATION

clk_process : process
begin
    while true loop
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end loop;
end process;


clk_process2 : process
begin
    while true loop
        clk2 <= '0';
        wait for clk_period2/2;
        clk2 <= '1';
        wait for clk_period2/2;
    end loop;
end process;

-- STIMULUS PROCESS

stim_proc : process
begin

-- RESET RELEASE

wait for 20 ns;
rst <= '0';

-- NORMAL OPERATION

for i in 0 to 10 loop
    J <= std_logic(to_unsigned(i,1)(0));
    K <= not J;
    wait for clk_period;
end loop;

-- METASTABILITY INJECTION

for i in 0 to 10 loop
    wait for 3 ns;
    J <= not J;
    injected_bugs <= injected_bugs + 1;
end loop;

wait for 20 ns;

-- RESET SEQUENCING BUG

J <= '1';
K <= '0';

wait for clk_period;

rst <= '1';
injected_bugs <= injected_bugs + 1;

wait for clk_period;

rst <= '0';

wait for 20 ns;

-- TIMING STRESS

for i in 0 to 20 loop
    wait until rising_edge(clk);
    J <= not J;
    K <= not K;
    injected_bugs <= injected_bugs + 1;
end loop;

-- CLOCK DOMAIN STRESS

for i in 0 to 10 loop
    wait until rising_edge(clk2);
    J <= not J;
    injected_bugs <= injected_bugs + 1;
end loop;

wait for 100 ns;

-- SIMULATION SUMMARY

report "------------------------------------";
report "TOTAL BUGS INJECTED = " & integer'image(injected_bugs);
report "TOTAL BUGS DETECTED = " & integer'image(detected_bugs);
report "------------------------------------";

wait for 100 ns;
std.env.stop;

end process;

end Behavioral;
