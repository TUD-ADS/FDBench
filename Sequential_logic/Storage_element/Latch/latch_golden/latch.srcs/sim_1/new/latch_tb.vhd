----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2025 11:33:45 PM
-- Design Name: 
-- Module Name: latch_tb - Behavioral
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

entity latch_tb is
-- Port ( );
end latch_tb;

architecture Behavioral of latch_tb is



signal L_in : std_logic := '0';
signal en   : std_logic := '0';
signal golden_L_out : std_logic;

--signal meta_L_out  : std_logic;

--signal bug_count : integer := 0;
signal bug_count_injected : integer := 0;

begin

    DUT : entity work.latch

    port map ( L_in => L_in,
               L_out => golden_L_out,
               en => en
               );
              
 stimulus : process

variable counter : integer := 0;

begin

 -- reset phase

    en  <= '0';
    L_in <= '0';
    wait for 20 ns;


-- stimulus patterns

    L_in <= '0'; en <= '1'; wait for 20 ns;
    L_in <= '1'; en <= '1'; wait for 20 ns;

    L_in <= '0'; en <= '0'; wait for 20 ns;
    L_in <= '1'; en <= '0'; wait for 20 ns;

    L_in <= '0'; en <= '1'; wait for 20 ns;
    L_in <= '1'; en <= '1'; wait for 20 ns;

    L_in <= '0'; en <= '1'; wait for 20 ns;
    L_in <= '1'; en <= '1'; wait for 20 ns;

    wait;
end process;
bug_count_injected <= 4;

end Behavioral;
