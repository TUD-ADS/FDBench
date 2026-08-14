----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 04:39:03 PM
-- Design Name: 
-- Module Name: async_counter_cgat - Behavioral
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

entity async_counter is
generic (n : natural := 4);
Port (
    clock   : in std_logic;
    reset   : in std_logic;
    counter : out unsigned(n-1 downto 0)
);
end async_counter;

architecture Behavioral of async_counter is

signal gated_clk : std_logic;
signal cnt : unsigned(n-1 downto 0) := (others=>'0');

begin

gated_clk <= clock and not reset;  -- bad clock gating

process(clock, reset)
begin
    if reset='1' then
        cnt <= (others=>'0');
    elsif rising_edge(gated_clk) then
        cnt <= cnt + 1;
    end if;
end process;

counter <= cnt;


end Behavioral;
