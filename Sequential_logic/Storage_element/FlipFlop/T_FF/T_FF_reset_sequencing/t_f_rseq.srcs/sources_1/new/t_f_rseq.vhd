----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 01:37:36 AM
-- Design Name: 
-- Module Name: t_f_rseq - Behavioral
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

entity t_f_rseq is
Port(
    T     : in std_logic;
    clock : in std_logic;
    reset : in std_logic;
    Q     : out std_logic
);
end t_f_rseq;

architecture Behavioral of t_f_rseq is

signal q_reg : std_logic := '0';

begin

process(clock)
begin
    if rising_edge(clock) then
        if T='1' then
            q_reg <= not q_reg;
        else
            q_reg <= '0';
        end if;
    end if;
end process;

Q <= q_reg;


end Behavioral;
