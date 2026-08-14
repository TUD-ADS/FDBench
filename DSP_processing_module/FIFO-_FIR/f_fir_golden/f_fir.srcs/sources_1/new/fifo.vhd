----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 12:14:06 PM
-- Design Name: 
-- Module Name: fifo - Behavioral
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

entity fifo is
generic (
        f_WIDTH : natural := 16;
        f_DEPTH : integer := 32
    );
Port ( 
        syn_clock      : in  std_logic;
        syn_reset    : in  std_logic;

        write     : in  std_logic;
        read      : in  std_logic;

        data_write  : in  std_logic_vector(f_WIDTH-1 downto 0);
        data_read : out std_logic_vector(f_WIDTH-1 downto 0);

        empty    : out std_logic;
       full     : out std_logic
        );
end fifo;

architecture Behavioral of fifo is

    type fifo_data is array (0 to f_DEPTH-1)
        of std_logic_vector(f_WIDTH-1 downto 0);

    signal r_fifo_data : fifo_data := (others => (others => '0'));

    signal wr_ptr : integer range 0 to f_DEPTH-1 := 0;
    signal rd_ptr : integer range 0 to f_DEPTH-1 := 0;
    signal count  : integer range 0 to f_DEPTH := 0;
    
    signal full_f  : std_logic;
    signal empty_f : std_logic;
    signal data_out_reg : std_logic_vector(f_WIDTH-1 downto 0) := (others => '0');

begin

fifo_proc: process(syn_clock)
    begin
        if (syn_clock'event and syn_clock= '1') then
            if syn_reset = '1' then
                wr_ptr <= 0;
                rd_ptr <= 0;
                count  <= 0;
                data_out_reg <= (others => '0');


            else
                if (write = '1' and full_f = '0') then
                    r_fifo_data(wr_ptr) <= data_write;
                    wr_ptr <= (wr_ptr + 1) mod f_DEPTH;
                    count <= count + 1;
                end if;

                -- READ
                if (read = '1' and empty_f = '0') then
                    data_out_reg <= r_fifo_data(rd_ptr);
                    rd_ptr <= (rd_ptr + 1) mod f_DEPTH;
                    count <= count - 1;
                end if;
            
            
            end if;
            end if;
            
end process;

    --data_read <= r_fifo_data(sp-1) when sp > 0 else (others => '0');
 data_read <= data_out_reg;

    empty_f <= '1' when count = 0     else '0';
    full_f  <= '1' when count = f_DEPTH else '0';
    
    empty <= empty_f;
    full  <= full_f;

end Behavioral;
