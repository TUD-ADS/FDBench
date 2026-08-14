----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 01:16:45 AM
-- Design Name: 
-- Module Name: parity_pkg - Behavioral
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

package parity_pkg is

    FUNCTION parity(inputs: std_logic_vector(7 downto 0)) RETURN std_logic;

end parity_pkg;

PACKAGE body parity_pkg is
	
    FUNCTION parity(inputs: std_logic_vector(7 downto 0)) RETURN std_logic is
    variable temp: std_logic;
    begin
	temp:='0';
	for i in 7 downto 0 loop
	    temp:=temp xor inputs(i);
	end loop;
	    return temp;
	end parity;		

end parity_pkg;
