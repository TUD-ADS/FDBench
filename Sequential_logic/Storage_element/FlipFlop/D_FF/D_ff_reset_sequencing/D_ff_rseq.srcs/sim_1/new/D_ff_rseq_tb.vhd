----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/06/2025 09:30:49 PM
-- Design Name: 
-- Module Name: D_F_tb - Behavioral
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

entity D_F_tb is
--  Port ( );
end D_F_tb;

architecture Behavioral of D_F_tb is
signal clk  : std_logic := '0';
signal clk2 : std_logic := '0';
signal rst  : std_logic := '1';

constant clk_period  : time := 10 ns;
constant clk_period2 : time := 14 ns;


-- INPUT SIGNAL


signal D : std_logic := '0';


-- OUTPUTS


signal Q_reset : std_logic;


-- BUG STATISTICS


signal injected_bugs : integer := 0;
signal detected_bugs : integer := 0;


-- TEST VECTOR COUNTER


--signal vector_count : integer := 0;

begin


-- DUT INSTANTIATION


GOLDEN : entity work.D_ff_rseq
port map(
    D => D,
    clock => clk,
    reset => rst,
    Q => Q_reset
);


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

stim_proc : process
begin


-- RESET RELEASE


wait for 20 ns;
rst <= '0';


-- NORMAL OPERATION


for i in 0 to 10 loop
    D <= std_logic(to_unsigned(i,1)(0));
    wait for clk_period;
end loop;


-- RESET SEQUENCING BUG


D <= '1';
wait for clk_period;

rst <= '1';
injected_bugs <= injected_bugs + 1;

wait for clk_period;

rst <= '0';

wait for 20 ns;


-- METASTABILITY INJECTION


for i in 0 to 10 loop
    wait for  10 ns;
    D <= not D;
    injected_bugs <= injected_bugs + 1;
end loop;

wait for 20 ns;





-- SIMULATION SUMMARY


report "------------------------------------";
report "TOTAL BUGS INJECTED = " & integer'image(injected_bugs);
report "TOTAL BUGS DETECTED = " & integer'image(detected_bugs);
report "------------------------------------";

wait for 100 ns;
std.env.stop;

end process;


monitor_proc : process(clk)

begin

if rising_edge(clk) then

--vector_count <= vector_count + 1;



-- RESET SEQUENCING CHECK
-- During reset output must stay 0


if rst = '1' then

    if Q_reset = '1' then

        detected_bugs <= detected_bugs + 1;

        assert false
        report "BUG DETECTED : reset_sequence violation"
        severity ERROR;

    end if;

end if;
end if;

end process;


end Behavioral;

