library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_overflow is
generic(
    f_WIDTH : natural := 16;
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
end FIFO_overflow;

architecture Behavioral of FIFO_overflow is

type fifo_data is array (0 to f_DEPTH-1)
    of std_logic_vector(f_WIDTH-1 downto 0);

signal mem : fifo_data := (others => (others=>'0'));

signal wr_ptr : integer range 0 to f_DEPTH-1 := 0;
signal rd_ptr : integer range 0 to f_DEPTH-1 := 0;
signal count  : integer range 0 to f_DEPTH := 0;

begin

process(syn_clock)
begin
    if rising_edge(syn_clock) then
        if syn_reset='1' then
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;

        else

            if write='1' then
                mem(wr_ptr) <= data_write;
                wr_ptr <= (wr_ptr + 1) mod f_DEPTH;
                count <= count + 2;
            end if;

            if read='1' and count > 0 then
                data_read <= mem(rd_ptr);
                rd_ptr <= (rd_ptr + 1) mod f_DEPTH;
                count <= count - 1;
            end if;

        end if;
    end if;
end process;

empty <= '1' when count=0 else '0';
full  <= '1' when count>=f_DEPTH else '0';

end Behavioral;