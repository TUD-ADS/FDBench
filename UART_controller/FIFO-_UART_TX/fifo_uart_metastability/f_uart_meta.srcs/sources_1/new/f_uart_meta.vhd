library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity f_uart is
generic(
    f_WIDTH : natural := 8;
    f_DEPTH : integer := 32;
    CLKS_PER_BIT : integer := 868
);
port(

    clk   : in std_logic;
    rst   : in std_logic;

    write      : in std_logic;
    data_write : in std_logic_vector(f_WIDTH-1 downto 0);

    tx_serial  : out std_logic;

    fifo_full  : out std_logic;
    fifo_empty : out std_logic

);
end f_uart;

architecture Behavioral of f_uart is

------------------------------------------------
-- FIFO signals
------------------------------------------------
signal fifo_read     : std_logic := '0';
signal fifo_data_out : std_logic_vector(f_WIDTH-1 downto 0);

signal fifo_full_s   : std_logic;
signal fifo_empty_s  : std_logic;

------------------------------------------------
-- UART signals
------------------------------------------------
signal uart_start : std_logic := '0';
signal uart_busy  : std_logic;
signal uart_done  : std_logic;

signal uart_data  : std_logic_vector(7 downto 0) := (others=>'0');

------------------------------------------------
-- FSM
------------------------------------------------
type state_type is (IDLE, READ_FIFO, START_UART);
signal state_reg : state_type := IDLE;

begin

------------------------------------------------
-- FIFO INSTANCE
------------------------------------------------
FIFO_INST : entity work.FIFO_meta
generic map(
    f_WIDTH => f_WIDTH,
    f_DEPTH => f_DEPTH
)
port map(

    syn_clock  => clk,
    syn_reset  => rst,

    write      => write,
    read       => fifo_read,

    data_write => data_write,
    data_read  => fifo_data_out,

    empty      => fifo_empty_s,
    full       => fifo_full_s

);

------------------------------------------------
-- UART INSTANCE
------------------------------------------------
UART_INST : entity work.UART_TX_meta
generic map(
    CLKS_PER_BIT => CLKS_PER_BIT
)
port map(

    clk       => clk,
    rst       => rst,

    tx_start  => uart_start,
    tx_data   => uart_data,

    tx_serial => tx_serial,
    tx_busy   => uart_busy,
    tx_done   => uart_done

);

------------------------------------------------
-- CONTROL FSM
------------------------------------------------
process(clk)
begin

if rising_edge(clk) then

    if rst='1' then

        state_reg  <= IDLE;
        fifo_read  <= '0';
        uart_start <= '0';
        uart_data  <= (others=>'0');

    else

        fifo_read  <= '0';
        uart_start <= '0';

        case state_reg is

        ------------------------------------------------
        when IDLE =>

            if fifo_empty_s='0' and uart_busy='0' then
                fifo_read <= '1';
                state_reg <= READ_FIFO;
            end if;

        ------------------------------------------------
        when READ_FIFO =>

            uart_data <= fifo_data_out(7 downto 0);
            state_reg <= START_UART;

        ------------------------------------------------
        when START_UART =>

            uart_start <= '1';
            state_reg <= IDLE;

        end case;

    end if;

end if;

end process;

------------------------------------------------
-- OUTPUT STATUS
------------------------------------------------

fifo_full  <= fifo_full_s;
fifo_empty <= fifo_empty_s;

end Behavioral;