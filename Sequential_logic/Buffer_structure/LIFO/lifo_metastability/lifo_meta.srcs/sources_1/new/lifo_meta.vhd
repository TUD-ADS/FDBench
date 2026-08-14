----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 03:41:01 PM
-- Design Name: 
-- Module Name: lifo_meta - Behavioral
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

entity lifo_meta is
generic (
        g_WIDTH : natural := 8;
        g_DEPTH : integer := 32
    );
Port ( 
        syn_clock      : in  std_logic;
        syn_reset    : in  std_logic;

        write     : in  std_logic;
        read      : in  std_logic;

        data_write  : in  std_logic_vector(g_WIDTH-1 downto 0);
        data_read : out std_logic_vector(g_WIDTH-1 downto 0);

        empty    : out std_logic;
        full     : out std_logic

        );
end lifo_meta;

architecture Behavioral of lifo_meta is


type lifo_array is array (0 to g_DEPTH-1)
    of std_logic_vector(g_WIDTH-1 downto 0);

signal mem : lifo_array;
signal counter : integer range 0 to g_DEPTH := 0;

signal write_async : std_logic;
signal write_sync  : std_logic;

    signal full_l  : std_logic;
    signal empty_l : std_logic;
    signal data_out_reg : std_logic_vector(g_WIDTH-1 downto 0) := (others => '0');

begin

-- asynchronous toggle generator
process(syn_clock)
begin
    if rising_edge(syn_clock) then
        write_async <= not write_async;
    end if;
end process;

-- only single synchronizer stage (BUG)
process(syn_clock)
begin
    if rising_edge(syn_clock) then
        write_sync <= write_async;
    end if;
end process;

process(syn_clock)
begin
    if rising_edge(syn_clock) then

        if write_sync='1' then
            mem(counter) <= data_write;
            counter <= counter + 1;
        elsif (read = '1' and empty_l = '0') then
                    data_out_reg <= mem(counter-1);
                    counter <= counter - 1;
        end if;

    end if;
end process;

data_read <= data_out_reg;

    empty_l <= '1' when counter = 0     else '0';
    full_l  <= '1' when counter > g_DEPTH else '0';
    
    empty <= empty_l;
    full  <= full_l;

end Behavioral;
