----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 03:51:29 PM
-- Design Name: 
-- Module Name: latch_meta - Behavioral
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

entity latch_meta is
    Port (
        L_in :    in std_logic;
        en :      in std_logic;
        L_out :   out std_logic
        );
end latch_meta;

architecture Behavioral of latch_meta is

signal meta_node : std_logic := '0';

begin

process(L_in)
begin

        meta_node <= L_in xor meta_node;   -- unstable feedback

end process;

process(en)
begin
    if en='1' then
        meta_node <= L_in xor meta_node;   -- unstable feedback
    end if;
end process;

L_out <= meta_node;



end Behavioral;
