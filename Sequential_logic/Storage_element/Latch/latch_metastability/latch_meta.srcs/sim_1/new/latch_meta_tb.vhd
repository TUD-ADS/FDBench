----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 03:51:47 PM
-- Design Name: 
-- Module Name: latch_meta_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity latch_meta_tb is
--  Port ( );
end latch_meta_tb;

architecture Behavioral of latch_meta_tb is



signal L_in : std_logic := '0';
signal en   : std_logic := '0';
signal meta_L_out : std_logic;
--signal bug_count : integer := 0;
signal bug_count_injected : integer := 0;

begin

    DUT : entity work.latch_meta

    port map ( L_in => L_in,
               L_out => meta_L_out,
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


monitor : process(en)
begin


if (en ='1') then
if meta_L_out /= L_in then
--bug_count <= bug_count + 1;
assert false report "Metastability bug detected" severity ERROR;
end if;
end if;


end process;

end Behavioral;
