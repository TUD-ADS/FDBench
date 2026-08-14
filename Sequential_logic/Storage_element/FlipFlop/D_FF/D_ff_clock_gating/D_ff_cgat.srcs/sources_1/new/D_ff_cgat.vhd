----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 11:57:18 PM
-- Design Name: 
-- Module Name: D_ff_cgat - Behavioral
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

entity D_ff_cgat is
Port(
        D      : in std_logic;
        clock  : in std_logic;
        reset  : in std_logic;
        Q      : out std_logic
);
end D_ff_cgat;

architecture Behavioral of D_ff_cgat is

signal gated_clock : std_logic;
signal enable      : std_logic := '1';
signal reg         : std_logic := '0';

begin

gated_clock <= clock xor reg;

process(gated_clock, reset)
begin
    if reset = '1' then
        reg <= '0';
    elsif rising_edge(gated_clock) then
        reg <= D;
    end if;
end process;

Q <= reg;


end Behavioral;
