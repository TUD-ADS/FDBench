----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 11:38:33 PM
-- Design Name: 
-- Module Name: reg_PISO_meta - Behavioral
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

entity reg_PISO_meta is
generic (n : natural := 8);
Port(
        I      : in  std_logic_vector(n-1 downto 0);
        clock  : in  std_logic;
        reset  : in  std_logic;
        load   : in  std_logic;
        Q      : out std_logic_vector(n-1 downto 0);
        S_out  : out std_logic
);
end reg_PISO_meta;

architecture Behavioral of reg_PISO_meta is

signal Q_reg      : std_logic_vector(n-1 downto 0);
signal meta_node  : std_logic;

begin

----------------------------------------------------------------
-- METASTABILITY-LIKE FEEDBACK NODE (SYNTHESIZABLE)
----------------------------------------------------------------
meta_node <= (load xor Q_reg(0)) xor meta_node;

----------------------------------------------------------------
-- PISO REGISTER
----------------------------------------------------------------
process(clock, reset)
begin

    if reset='1' then
        Q_reg <= (others=>'0');

    elsif rising_edge(clock) then

        if meta_node='1' then

            if load='1' then
                Q_reg <= I;
            else
                Q_reg <= Q_reg(n-2 downto 0) & '0';
            end if;

        end if;

    end if;

end process;

Q <= Q_reg;
S_out <= Q_reg(n-1);

end Behavioral;