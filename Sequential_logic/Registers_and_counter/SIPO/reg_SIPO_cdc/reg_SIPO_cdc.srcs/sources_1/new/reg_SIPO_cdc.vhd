----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 10:18:11 PM
-- Design Name: 
-- Module Name: reg_SIPO_cdc - Behavioral
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

entity reg_SIPO_cdc is
generic ( n : natural := 8 );
Port (
    clk_A : in  std_logic;  -- source domain
    clk_B : in  std_logic;  -- destination domain
    reset : in  std_logic;
    I     : in  std_logic;
    load  : in  std_logic;  -- async control (CDC bug)
    Q     : out std_logic_vector(n-1 downto 0)
);
end reg_SIPO_cdc;

architecture Behavioral of reg_SIPO_cdc is

signal Q_reg   : std_logic_vector(n-1 downto 0) := (others => '0');
signal data_A  : std_logic := '0';
signal load_A  : std_logic := '0';

begin

------------------------------------------------------------------
-- DOMAIN A (Source Domain)
------------------------------------------------------------------
process(clk_A, reset)
begin
    if reset = '1' then
        data_A <= '0';
        load_A <= '0';

    elsif rising_edge(clk_A) then
        data_A <= I;        -- sampled in clk_A domain
        load_A <= load;     -- passed without sync (BUG)
    end if;
end process;

------------------------------------------------------------------
-- DOMAIN B (Destination Domain - BUG HERE)
------------------------------------------------------------------
process(clk_B, reset)
begin
    if reset = '1' then
        Q_reg <= (others => '0');

    elsif rising_edge(clk_B) then

        -- CDC BUG: using unsynchronized signals
        if load_A = '1' then
            Q_reg <= Q_reg(n-2 downto 0) & data_A;
        end if;

    end if;
end process;

Q <= Q_reg;

end Behavioral;
