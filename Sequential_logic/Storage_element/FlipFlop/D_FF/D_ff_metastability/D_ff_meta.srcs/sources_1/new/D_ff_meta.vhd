----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 11:32:28 PM
-- Design Name: 
-- Module Name: D_ff_meta - Behavioral
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

entity D_ff_meta is
Port(
        D     : in std_logic;
        clock : in std_logic;
        reset : in std_logic;
        Q     : out std_logic
);
end D_ff_meta;

architecture Behavioral of D_ff_meta is

signal async_toggle : std_logic := '0';
signal sync_ff      : std_logic := '0';

begin

-- asynchronous source generation
process(clock)
begin
    if rising_edge(clock) then
        async_toggle <= not async_toggle;
    end if;
end process;

-- metastable prone sampling
process(clock, reset)
begin

    if rising_edge(clock) then
        sync_ff <= async_toggle;
    end if;
end process;

Q <= sync_ff;

end Behavioral;