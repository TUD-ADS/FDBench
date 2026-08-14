----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2025 10:31:24 PM
-- Design Name: 
-- Module Name: jk_f - Behavioral
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

entity jk_f is
    Port ( 
       clock:		in std_logic;
	   J, K:		in std_logic;
	   reset:		in std_logic;
	   Q, Qbar:	    out std_logic);
end jk_f;

architecture Behavioral of jk_f is

    -- defined the useful signals here

    signal state: std_logic;
    signal input: std_logic_vector(1 downto 0);

begin

    -- combined inputs into vector
    input <= J & K;		

    p: process(clock, reset) is
    begin
	
	if (reset='1') then
	    state <= '0';
	elsif (rising_edge(clock)) then

            -- compare to the truth table
	    case (input) is
		when "11" =>
		    state <= not state;
		when "10" =>
		    state <= '1';
		when "01" =>
		    state <= '0';
		when others =>
		    null;
		end case;
	end if;

    end process;
	
    -- concurrent statements
    Q <= state;
    Qbar <= not state;

end Behavioral;
