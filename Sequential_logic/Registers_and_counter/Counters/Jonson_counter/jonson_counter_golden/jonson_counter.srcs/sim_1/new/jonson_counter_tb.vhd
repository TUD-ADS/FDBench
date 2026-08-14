----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 03:59:41 AM
-- Design Name: 
-- Module Name: jonson_counter_tb - Behavioral
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

entity jonson_counter_tb is
--  Port ( );
end jonson_counter_tb;

architecture Behavioral of jonson_counter_tb is

    signal T_clock : std_logic;
    signal T_reset : std_logic;
    signal T_counter : std_logic_vector(3 downto 0);
    
    constant clk_period : time := 10 ns;

begin

    dut : entity work.jonson_counter

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
    
    -- Apply reset
    T_reset <= '1';
    wait for 20 ns;

    assert T_counter = "0000"
        report "ERROR: Counter not reset to 0000"
        severity error;

    -- Release reset and check first few counts
    T_reset <= '0';

    wait for 10 ns;
    assert T_counter = "0001"
        report "ERROR: Expected 0001"
        severity error;

    wait for 10 ns;
    assert T_counter = "0011"
        report "ERROR: Expected 0011"
        severity error;

    wait for 10 ns;
    assert T_counter = "0111"
        report "ERROR: Expected 0111"
        severity error;

    wait for 10 ns;
    assert T_counter = "1111"
        report "ERROR: Expected 1111"
        severity error;

    -- Apply reset again
    T_reset <= '1';
    wait for 10 ns;

    assert T_counter = "0000"
        report "ERROR: Counter not reset correctly (second reset)"
        severity error;

    -- End simulation
               
      wait for 50 ns;
      
      
      report "Simulation completed." severity note;
      std.env.stop; 
    
    end process;


end Behavioral;
