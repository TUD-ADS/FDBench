----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 11:39:14 PM
-- Design Name: 
-- Module Name: reg_PISO_cdc - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg_PISO_cdc is
generic (n: natural := 8);
Port ( 
    clk_A  : in  std_logic;  -- source domain
    clk_B  : in  std_logic;  -- destination domain
    reset  : in  std_logic;
    load   : in  std_logic;  -- async signal (CDC bug!)
    I      : in  std_logic_vector(n-1 downto 0);
    Q      : out std_logic_vector(n-1 downto 0);
    S_out  : out std_logic
);
end reg_PISO_cdc;

architecture Behavioral of reg_PISO_cdc is

signal Q_reg : std_logic_vector(n-1 downto 0) := (others => '0');
signal load_A : std_logic := '0';

begin

-- Domain A: generate load (source domain)
process(clk_A, reset)
begin
    if reset = '1' then
        load_A <= '0';
    elsif rising_edge(clk_A) then
        load_A <= load;   -- no sync, just pass through
    end if;
end process;


-- Domain B: use async signal directly (BUG HERE ?)
process(clk_B, reset)
begin
    if reset = '1' then
        Q_reg <= (others => '0');

    elsif rising_edge(clk_B) then
        if load_A = '1' then   -- ? UNSYNCHRONIZED CDC
            Q_reg <= I;
        else
            Q_reg <= Q_reg(n-2 downto 0) & '0';
        end if;
    end if;
end process;

Q     <= Q_reg;
S_out <= Q_reg(n-1);

end Behavioral;
