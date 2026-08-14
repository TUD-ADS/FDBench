----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/10/2025 12:38:32 PM
-- Design Name: 
-- Module Name: reg_SIPO - Behavioral
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

entity reg_SIPO is

generic ( n : natural := 8 );
Port (
        I: in std_logic;
        clock: in std_logic;
        reset: in std_logic;
        load:  in std_logic;
        Q: out std_logic_vector(n-1 downto 0)
         );
end reg_SIPO;

architecture Behavioral of reg_SIPO is

signal Q_reg: std_logic_vector(n-1 downto 0);

begin
    process(clock, reset)
    begin
    if (reset = '1') then
        Q_reg <= (Q_reg'range => '0');
    elsif (clock = '1' and clock'event) then
        if (load = '1') then
            Q_reg <= Q_reg(n-2 downto 0) & I;
        else
            Q_reg <= Q_reg;
        end if;
    end if;     
    end process;
    
    -- concurrent statement
    Q <= Q_reg;
end Behavioral;
