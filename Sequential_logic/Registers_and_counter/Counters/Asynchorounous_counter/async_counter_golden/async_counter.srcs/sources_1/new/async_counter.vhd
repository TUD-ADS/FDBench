----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 04:28:41 AM
-- Design Name: 
-- Module Name: async_counter - Behavioral
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


-- async reset counter



entity async_counter is
generic (n : natural := 4);
Port ( 
        clock : in std_logic;
        reset : in std_logic;
        counter : out unsigned(n-1 downto 0)       
);
end async_counter;

architecture Behavioral of async_counter is
    signal cnt : unsigned(n-1 downto 0) :=(others => '0');
    
begin
    asyc_counter: process(clock, reset)
    begin
            if reset = '1' then
                cnt <= (others => '0');
            elsif (clock'event and clock= '1') then
            if cnt = 2**n - 1 then
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
            end if;
            end if;
    end process;

    counter <= cnt;



end Behavioral;
