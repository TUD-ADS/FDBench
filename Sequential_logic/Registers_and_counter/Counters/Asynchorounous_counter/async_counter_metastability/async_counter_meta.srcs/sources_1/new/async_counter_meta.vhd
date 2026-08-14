----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 04:34:53 PM
-- Design Name: 
-- Module Name: async_counter_meta - Behavioral
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

entity async_counter_meta is
generic (n : natural := 4);
Port (
    clock   : in std_logic;
    reset   : in std_logic;
    counter : out unsigned(n-1 downto 0)
);

end async_counter_meta;

architecture Behavioral of async_counter_meta is

signal cnt : unsigned(n-1 downto 0);
signal meta_node : std_logic := '0';

begin


process(clock, reset)
begin
meta_node <= clock xor meta_node;  -- unstable feedback

    if rising_edge(clock) then
        if meta_node='1' then
            cnt <= cnt + 1;
        end if;
    end if;
end process;

counter <= cnt;


end Behavioral;
