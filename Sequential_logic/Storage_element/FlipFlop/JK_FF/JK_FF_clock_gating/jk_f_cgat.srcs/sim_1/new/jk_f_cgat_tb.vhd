----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 02:54:36 AM
-- Design Name: 
-- Module Name: jk_f_cgat_tb - Behavioral
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

entity jk_f_cgat_tb is
--  Port ( );
end jk_f_cgat_tb;

architecture Behavioral of jk_f_cgat_tb is


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

signal Q_bug : std_logic;
signal Qbar_bug : std_logic;



-- BUG STATISTICS

signal injected_bugs : integer := 0;
signal detected_bugs : integer := 0;

begin

-- DUT INSTANTIATIONS

GOLDEN : entity work.jk_f_cgat
port map(
    clock => clk,
    J => J,
    K => K,
    reset => rst,
    Q => Q_bug,
    Qbar => Qbar_bug
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



-- SIMULATION SUMMARY

report "------------------------------------";
report "TOTAL BUGS INJECTED = " & integer'image(injected_bugs);
report "TOTAL BUGS DETECTED = " & integer'image(detected_bugs);
report "------------------------------------";

wait for 100 ns;
std.env.stop;

end process;

-- MONITOR PROCESS

monitor_proc : process(clk)

begin

-- CLOCKED CHECKS

if rising_edge(clk) then



-- CLOCK GATING BUG

if (Q_bug = '0' and J = '1' and K = '0')  then

    detected_bugs <= detected_bugs + 1;

    assert false
    report "BUG DETECTED : clock_gatting mismatch"
    severity ERROR;

end if;



end if;




end process;


end Behavioral;
