----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2025 11:33:19 PM
-- Design Name: 
-- Module Name: latch - Behavioral
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

entity latch is
    Port (
        L_in :    in std_logic;
        en :      in std_logic;
        L_out :   out std_logic
        );
end latch;

architecture Behavioral of latch is

begin

    process(L_in, en)
    begin
        if (en='1') then
            -- no clock signal here
	    L_out <= L_in;
	    else 
	    L_out <= '0';
	end if;
    end process;


end Behavioral;
