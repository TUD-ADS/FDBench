----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 09:10:17 PM
-- Design Name: 
-- Module Name: ring_counter_overflow_tb - Behavioral
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

entity ring_counter_overflow_tb is
--  Port ( );
end ring_counter_overflow_tb;

architecture Behavioral of ring_counter_overflow_tb is


    
    constant clk_period : time := 10 ns;
    signal T_clock : std_logic:= '0';
    signal T_reset : std_logic := '1';
    signal T_counter : std_logic_vector(3 downto 0);
    signal rcount : integer := 0;
    signal bug_count : integer := 0;
    signal prev_counter : unsigned(3 downto 0) := (others=>'0');

begin

dut : entity work.ring_counter_overflow

    port map (
               clock => T_clock,
               reset => T_reset,
               counter => T_counter
               );
              

clk_process : process
begin
   -- while true loop
        T_clock <= '0';
        wait for clk_period/2;

        T_clock <= '1';
        wait for clk_period/2;
    --end loop;
end process;
stimuli : process
begin
        wait for 30 ns; 
            T_reset <= '0';
            
       wait for 100 ns; 
            T_reset <= '1'; 
       wait for 50 ns;
            T_reset <= '0';   
        
wait for 100 ns;
std.env.stop;
end process;

-- MONITOR

process(T_clock)
begin

    if rising_edge(T_clock) then

        if unsigned(T_counter) = prev_counter + 2 and T_reset='0' then
        bug_count <= bug_count + 1;
        assert false
        report "BUG DETECTED : OVERFLOW_DETECTED violation risk"
        severity ERROR;
        end if;
        prev_counter <= unsigned(T_counter);
        end if;

end process;




end Behavioral;
