----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 10:32:45 AM
-- Design Name: 
-- Module Name: lifo - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lifo is
generic (
        g_WIDTH : natural := 8;
        g_DEPTH : natural := 32
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
end lifo;

architecture Behavioral of lifo is

    type lifo_data is array (0 to g_DEPTH-1)
        of std_logic_vector(g_WIDTH-1 downto 0);

    signal r_lifo_data : lifo_data := (others => (others => '0'));

    signal counter  : integer range 0 to g_DEPTH := 0;  -- lifo pointer
    
    signal full_l  : std_logic;
    signal empty_l : std_logic;
    signal data_out_reg : std_logic_vector(g_WIDTH-1 downto 0) := (others => '0');

begin

    lifo_proc: process(syn_clock, syn_reset)
    begin
        if (rising_edge(syn_clock)) then
            if syn_reset = '1' then
                counter <= 0;
                r_lifo_data <= (others => (others=>'0'));
                data_out_reg <= (others => '0');
                
            else
                -- PUSH
                if (write = '1' and full_l = '0') then
                    r_lifo_data(counter) <= data_write;
                    counter <= counter + 1; 

                -- POP
                elsif (read = '1' and empty_l = '0') then
                    data_out_reg <= r_lifo_data(counter-1);
                    counter <= counter - 1;
                end if;
            end if;
        end if;
    end process;
    
    data_read <= data_out_reg;

    empty_l <= '1' when counter = 0     else '0';
    full_l  <= '1' when counter >= g_DEPTH else '0';
    
    empty <= empty_l;
    full  <= full_l;
end Behavioral;
