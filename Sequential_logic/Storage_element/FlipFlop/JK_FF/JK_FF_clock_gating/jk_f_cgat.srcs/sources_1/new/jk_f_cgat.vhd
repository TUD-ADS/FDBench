----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 02:54:17 AM
-- Design Name: 
-- Module Name: jk_f_cgat - Behavioral
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

entity jk_f_cgat is
    Port ( 
       clock:		in std_logic;
	   J, K:		in std_logic;
	   reset:		in std_logic;
	   Q, Qbar:	    out std_logic);
end jk_f_cgat;

architecture Behavioral of jk_f_cgat is

signal state : std_logic := '0';
signal gated_clock : std_logic;

begin

gated_clock <= clock xor J;   -- incorrect clock gating

process(gated_clock, reset)
begin

    if reset='1' then
        state <= '0';

    elsif rising_edge(clock) then
        state <= K;
    end if;

end process;

Q <= state;
Qbar <= not state;



end Behavioral;
