----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/06/2025 09:29:25 PM
-- Design Name: 
-- Module Name: D_F - Behavioral
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

entity D_F is
Port ( 
            D      : in std_logic;
            clock  : in std_logic;
            reset  : in std_logic;
            Q      : out std_logic);
end D_F;

architecture Behavioral of D_F is

begin
-- D flip flop working 
    D_flop : process(clock, reset)
    begin
        if (reset = '1') then
           Q <= '0';
        elsif (clock'event and clock= '1') then
            Q <= D;
        end if;
    end process;

end Behavioral;
