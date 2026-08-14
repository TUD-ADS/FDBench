----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2025 11:15:03 PM
-- Design Name: 
-- Module Name: t_f - Behavioral
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

entity t_f is
    Port ( 
        T:     in std_logic;
        clock: in std_logic;
        reset: in std_logic;
        Q:     out std_logic
        );
end t_f;

architecture Behavioral of t_f is

signal q_reg : std_logic := '0';

begin
    process(clock, reset)
    begin
        if (reset = '1') then
            q_reg <= '0';
        elsif (clock'event and clock= '1') then
            if T = '1' then
                q_reg <= not q_reg;      -- toggle
            else
                q_reg <= q_reg;          -- hold
            end if;
        end if;
    end process;
    Q <= q_reg;
end Behavioral;
