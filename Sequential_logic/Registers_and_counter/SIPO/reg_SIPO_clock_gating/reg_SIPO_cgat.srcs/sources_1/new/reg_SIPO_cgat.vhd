----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 10:19:11 PM
-- Design Name: 
-- Module Name: reg_SIPO_cgat - Behavioral
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

entity reg_SIPO_cgat is
generic ( n : natural := 8 );
Port (
        I: in std_logic;
        clock: in std_logic;
        reset: in std_logic;
        load:  in std_logic;
        Q: out std_logic_vector(n-1 downto 0)
         );end reg_SIPO_cgat;

architecture Behavioral of reg_SIPO_cgat is

signal Q_reg : std_logic_vector(n-1 downto 0);
signal gated_clk : std_logic;
begin

gated_clk <= clock and load;

process(gated_clk, reset)
begin
    if reset='1' then
        Q_reg <= (others=>'0');
    elsif rising_edge(gated_clk) then
        Q_reg <= Q_reg(n-2 downto 0) & I;
    end if;
end process;

Q <= Q_reg;


end Behavioral;
