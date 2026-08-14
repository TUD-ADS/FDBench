----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 03:59:12 AM
-- Design Name: 
-- Module Name: jonson_counter - Behavioral
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

entity jonson_counter is
Port (
        clock : in std_logic;
        reset : in std_logic;
        counter : out std_logic_vector(3 downto 0)
        );
end jonson_counter;

architecture Behavioral of jonson_counter is
     signal reg : std_logic_vector(3 downto 0);
begin

    process(clock, reset)
    begin
        if reset = '1' then
            reg <= "0000";          -- initial one-hot value
        elsif (clock'event and clock= '1') then
            reg <= reg(2 downto 0) & not reg(3);  -- rotate left
        end if;
    end process;

    counter <= reg;

end Behavioral;
