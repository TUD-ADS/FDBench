----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 03:42:35 PM
-- Design Name: 
-- Module Name: lifo_overflow - Behavioral
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

entity lifo_overflow is
--  Port ( );

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
end lifo_overflow;

architecture Behavioral of lifo_overflow is


    type lifo_data is array (0 to g_DEPTH-1)
        of std_logic_vector(g_WIDTH-1 downto 0);

    signal r_lifo_data : lifo_data := (others => (others => '0'));

    signal counter  : integer range -1 to g_DEPTH+3 := 0;  -- lifo pointer
    
    signal full_l  : std_logic;
    signal empty_l : std_logic;
    signal data_out_reg : std_logic_vector(g_WIDTH-1 downto 0) := (others => '0');

begin

    lifo_proc: process(syn_clock)
    begin
        if (syn_clock'event and syn_clock= '1') then
            if syn_reset = '1' then
                counter <= 0;
                r_lifo_data <= (others => (others=>'0'));
                data_out_reg <= (others => '0');
                
            else
                -- PUSH
                if (write = '1' and full_l = '0') then
                    r_lifo_data(counter) <= data_write;
                    counter <= counter + 2; 

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
