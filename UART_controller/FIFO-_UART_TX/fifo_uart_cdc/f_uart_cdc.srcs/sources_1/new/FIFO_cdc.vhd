----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2026 04:40:27 PM
-- Design Name: 
-- Module Name: FIFO_cdc - Behavioral
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

entity FIFO_cdc is
generic(
    f_WIDTH : natural := 8;
    f_DEPTH : integer := 32
);
port(
    syn_clock  : in  std_logic;
    syn_reset  : in  std_logic;

    write      : in  std_logic;
    read       : in  std_logic;

    data_write : in  std_logic_vector(f_WIDTH-1 downto 0);
    data_read  : out std_logic_vector(f_WIDTH-1 downto 0);

    empty      : out std_logic;
    full       : out std_logic
);
end FIFO_cdc;

architecture Behavioral of FIFO_cdc is

type fifo_data is array (0 to f_DEPTH-1)
    of std_logic_vector(f_WIDTH-1 downto 0);

signal mem : fifo_data := (others => (others => '0'));

signal wr_ptr : integer range 0 to f_DEPTH-1 := 0;
signal rd_ptr : integer range 0 to f_DEPTH-1 := 0;

signal wr_count : integer range 0 to f_DEPTH := 0;
signal rd_count : integer range 0 to f_DEPTH := 0;

signal fake_rd_clk : std_logic := '0';

begin

---------------------------------------------------------
-- Fake read clock generation (asynchronous domain)
---------------------------------------------------------
fake_clk : process(syn_clock)
begin

fake_rd_clk <= not syn_clock;
   
end process;

---------------------------------------------------------
-- WRITE DOMAIN
---------------------------------------------------------
process(syn_clock)
begin
    if rising_edge(syn_clock) then
        if syn_reset='1' then
            wr_ptr <= 0;
            wr_count <= 0;

        else
            if write='1' then
                mem(wr_ptr) <= data_write;
                wr_ptr <= (wr_ptr + 1) mod f_DEPTH;
                wr_count <= wr_count + 1;
            end if;
        end if;
    end if;
end process;

---------------------------------------------------------
-- READ DOMAIN
---------------------------------------------------------
process(fake_rd_clk)
begin
    if rising_edge(fake_rd_clk) then
        if syn_reset='1' then
            rd_ptr <= 0;
            rd_count <= 0;

        else
            if read='1' then
                data_read <= mem(rd_ptr);
                rd_ptr <= (rd_ptr + 1) mod f_DEPTH;
                rd_count <= rd_count + 1;
            end if;
        end if;
    end if;
end process;

---------------------------------------------------------
-- Incorrect flags (CDC bug)
---------------------------------------------------------
empty <= '1' when wr_count = rd_count else '0';
full  <= '1' when (wr_count - rd_count) = f_DEPTH else '0';

end Behavioral;