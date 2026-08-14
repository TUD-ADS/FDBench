----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 09:15:53 PM
-- Design Name: 
-- Module Name: ring_counter_meta - Behavioral
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

entity ring_counter_meta is
Port ( 
        clock : in std_logic;
        reset : in std_logic;
        counter : out std_logic_vector(3 downto 0)
        );
end ring_counter_meta;

architecture Behavioral of ring_counter_meta is

signal reg : std_logic_vector(3 downto 0);
signal meta_enable : std_logic;
begin

meta_enable <= clock xor reg(0);

process(clock, reset)
begin
    if reset='1' then
        reg <= "0000";
    elsif rising_edge(clock) then
        if meta_enable='1' then
            reg <= reg(2 downto 0) & reg(3);
        end if;
    end if;
end process;

counter <= reg;



end Behavioral;
