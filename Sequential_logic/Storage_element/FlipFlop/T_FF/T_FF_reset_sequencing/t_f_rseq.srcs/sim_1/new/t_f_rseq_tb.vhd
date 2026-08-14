----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Testbench for T Flip-Flop Bug Detection
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity t_f_tb is
end t_f_tb;

architecture Behavioral of t_f_tb is

-- CLOCK SIGNALS

signal clk  : std_logic := '0';
signal clk2 : std_logic := '0';
signal rst  : std_logic := '1';

constant clk_period  : time := 10 ns;
constant clk_period2 : time := 14 ns;

-- INPUT SIGNAL

signal T : std_logic := '0';

-- OUTPUTS

signal Q_reset : std_logic;


-- BUG STATISTICS

signal injected_bugs : integer := 0;
signal detected_bugs : integer := 0;

begin

-- GOLDEN REFERENCE

GOLDEN : entity work.t_f_rseq
port map(
    T     => T,
    clock => clk,
    reset => rst,
    Q     => Q_reset
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
    --while true loop
        clk2 <= '0';
        wait for clk_period2/2;
        clk2 <= '1';
        wait for clk_period2/2;
    --end loop;
end process;

-- STIMULUS PROCESS

stim_proc : process
begin

-- RESET RELEASE

wait for 20 ns;
rst <= '0';

-- NORMAL OPERATION

for i in 0 to 10 loop
    T <= std_logic(to_unsigned(i,1)(0));
    wait for clk_period;
end loop;



for i in 0 to 10 loop
    wait for 3 ns;
    T <= not T;
    injected_bugs <= injected_bugs + 1;
end loop;

wait for 20 ns;

-- RESET SEQUENCING BUG

T <= '1';
wait for clk_period;

rst <= '1';
injected_bugs <= injected_bugs + 1;

wait for clk_period;

rst <= '0';

wait for 20 ns;

-- TIMING STRESS

for i in 0 to 20 loop
    wait until rising_edge(clk);
    T <= not T;
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

-- MONITOR PROCESS

monitor_proc : process(clk)



begin

if rising_edge(clk) then

-- RESET SEQUENCING CHECK

if rst = '1' then

    if Q_reset /= '0' then

        detected_bugs <= detected_bugs + 1;

        assert false
        report "BUG DETECTED : reset_sequence violation"
        severity ERROR;

    end if;

end if;

end if;

end process;
end Behavioral;