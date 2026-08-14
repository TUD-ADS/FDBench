----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 11:29:45 PM
-- Design Name: 
-- Module Name: D_ff_rseq - Behavioral
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

entity D_ff_rseq is
Port(
        D      : in std_logic;
        clock  : in std_logic;
        reset  : in std_logic;
        Q      : out std_logic
);
end D_ff_rseq;

architecture Behavioral of D_ff_rseq is

signal reg : std_logic := '0';

begin

process(clock)
begin
    if rising_edge(clock) then

            reg <= D;
    end if;
end process;

Q <= reg;


end Behavioral;
