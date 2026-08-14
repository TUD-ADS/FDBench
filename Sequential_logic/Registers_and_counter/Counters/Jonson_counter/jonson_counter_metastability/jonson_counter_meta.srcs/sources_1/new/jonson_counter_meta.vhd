----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 08:06:25 PM
-- Design Name: 
-- Module Name: jonson_counter_meta - Behavioral
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

entity jonson_counter_meta is
Port (
        clock : in std_logic;
        reset : in std_logic;
        counter : out std_logic_vector(3 downto 0)
        );
end jonson_counter_meta;

architecture Behavioral of jonson_counter_meta is

signal reg : std_logic_vector(3 downto 0);
signal meta_node : std_logic := '0';
begin

meta_node <= clock xor reg(0);   -- internal unstable feedback

process(clock, reset)
begin
    if reset='1' then
        reg <= "0000";
    elsif rising_edge(clock) then
        if meta_node='1' then
            reg <= reg(2 downto 0) & not reg(3);
        end if;
    end if;
end process;

counter <= reg;


end Behavioral;
