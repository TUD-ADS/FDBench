----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 03:32:19 AM
-- Design Name: 
-- Module Name: ring_counter_tb - Behavioral
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

entity ring_counter_tb is
--  Port ( );
end ring_counter_tb;

architecture Behavioral of ring_counter_tb is

    signal T_clock : std_logic;
    signal T_reset : std_logic:='1';
    signal T_counter : std_logic_vector(3 downto 0);
    
    constant clk_period : time := 10 ns;

begin

    dut : entity work.ring_counter

    port map (
               Clock => T_clock,
               reset => T_reset,
               counter => T_counter
               );
              

    clk_process : process
    begin
        T_clock <= '0';
        wait for clk_period/2;
        T_clock <= '1';
        wait for clk_period/2;
    
    end process;
    
    stim : process
    begin
    
      wait for 100 ns; 
 
      T_reset <= '1';
         
      wait for 20 ns; 
         
      T_reset <= '0';
      
      wait for 50 ns;
      
      T_reset <= '1';
               
      wait for 50 ns;
      
      T_reset <= '0';
      
      wait for 150 ns;
      report "Simulation completed." severity note;
      std.env.stop; 
    
    end process;


end Behavioral;
