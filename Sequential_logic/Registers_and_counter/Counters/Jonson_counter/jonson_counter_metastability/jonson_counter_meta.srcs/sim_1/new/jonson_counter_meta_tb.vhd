----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 08:06:43 PM
-- Design Name: 
-- Module Name: jonson_counter_meta_tb - Behavioral
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

entity jonson_counter_meta_tb is

end jonson_counter_meta_tb;

architecture Behavioral of jonson_counter_meta_tb is

        signal rcount : integer := 0;
    signal T_clock : std_logic;
    signal T_reset : std_logic:= '1';
    signal T_counter : std_logic_vector(3 downto 0);
    signal bug_count : integer := 0;
    signal prev_counter : unsigned(3 downto 0) := (others=>'0');
    constant clk_period : time := 10 ns;

begin

    dut : entity work.jonson_counter_meta

    port map (
               Clock => T_clock,
               reset => T_reset,
               counter => T_counter
               );
              

clk_process : process
begin
   --while true loop
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

if (rising_edge(T_clock)) then
        if (unsigned(T_counter) /= prev_counter + 1 and T_reset='0') then
        bug_count <= bug_count + 1;
        assert false
        report "BUG DETECTED : METASTABILITY violation risk"
        severity ERROR;
        end if;
        prev_counter <= unsigned(T_counter);
end if;
end process;


end Behavioral;
