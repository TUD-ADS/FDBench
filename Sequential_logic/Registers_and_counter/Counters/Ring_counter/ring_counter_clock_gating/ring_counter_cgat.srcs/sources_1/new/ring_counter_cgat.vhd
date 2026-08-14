----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 09:09:00 PM
-- Design Name: 
-- Module Name: ring_counter_cgat - Behavioral
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

entity ring_counter_cgat is
Port ( 
        clock : in std_logic;
        reset : in std_logic;
        counter : out std_logic_vector(3 downto 0)
        );
end ring_counter_cgat;

architecture Behavioral of ring_counter_cgat is

signal reg : std_logic_vector(3 downto 0);
signal gated_clk : std_logic;
begin

gated_clk <= clock and reg(0);

process(gated_clk, reset)
begin
    if reset='1' then
        reg <= "0001";
    elsif rising_edge(gated_clk) then
        reg <= reg(2 downto 0) & reg(3);
    end if;
end process;

counter <= reg;


end Behavioral;
