----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 03:41:47 PM
-- Design Name: 
-- Module Name: lifo_cdc - Behavioral
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lifo_cdc is
generic (
    g_WIDTH : natural := 8;
    g_DEPTH : integer := 32
);
Port ( 
    syn_clock   : in  std_logic;
    syn_reset   : in  std_logic;

    write       : in  std_logic;
    read        : in  std_logic;

    data_clk1  : in  std_logic_vector(g_WIDTH-1 downto 0);
    data_read   : out std_logic_vector(g_WIDTH-1 downto 0);

    empty       : out std_logic;
    full        : out std_logic
);
end lifo_cdc;

architecture Behavioral of lifo_cdc is

-- intentionally generated second clock (bad practice)
signal clk1 : std_logic := '0';

type lifo_array is array (0 to g_DEPTH-1)
    of std_logic_vector(g_WIDTH-1 downto 0);

signal mem : lifo_array := (others => (others => '0'));

-- two pointers in different clock domains
signal wr_ptr : integer range -1 to g_DEPTH+2 := 0;
signal rd_ptr : integer range -1 to g_DEPTH+2 := 0;

signal full_l  : std_logic;
signal empty_l : std_logic;

begin

------------------------------------------------
-- BUG: create fake second clock
------------------------------------------------
clk1 <= not syn_clock;

------------------------------------------------
-- WRITE DOMAIN (clk1)
------------------------------------------------
process(clk1)
begin
if rising_edge(clk1) then

    if syn_reset='1' then
        wr_ptr <= 0;

    else
        if (write = '1' and full_l = '0') then
            mem(wr_ptr) <= data_clk1;
            wr_ptr <= wr_ptr + 1;
        end if;

    end if;

end if;
end process;

------------------------------------------------
-- READ DOMAIN (syn_clock)
------------------------------------------------
process(syn_clock)
begin
if rising_edge(syn_clock) then

    if syn_reset='1' then
        rd_ptr <= 0;

    else
        if (read = '1' and empty_l = '0') then
            rd_ptr <= rd_ptr + 1;
        end if;

    end if;

end if;
end process;

------------------------------------------------
-- DATA OUTPUT
------------------------------------------------
data_read <= mem(wr_ptr-1) when wr_ptr > 0 else (others=>'0');

------------------------------------------------
-- BUGGY STATUS FLAGS
-- no synchronization between domains
------------------------------------------------
empty_l <= '1' when wr_ptr = rd_ptr else '0';
full_l  <= '1' when wr_ptr >= g_DEPTH else '0';

empty <= empty_l;
full  <= full_l;

end Behavioral;