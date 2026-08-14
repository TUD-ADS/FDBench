library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity f_uart_rseq_tb is
end f_uart_rseq_tb;

architecture tb of f_uart_rseq_tb is


-- DUT parameters


constant WIDTH : natural := 8;
constant DEPTH : integer := 32;
constant CLKS_PER_BIT : integer := 868;


-- signals


signal clk   : std_logic := '0';
signal rst   : std_logic := '0';

signal write      : std_logic := '0';
signal data_write : std_logic_vector(WIDTH-1 downto 0) := (others=>'0');

signal tx_serial  : std_logic;
signal fifo_full  : std_logic;
signal fifo_empty : std_logic;


-- clock


constant CLK_PERIOD : time := 10 ns;


-- bug mode selection







-- DUT


begin

DUT : entity work.f_uart_rseq
generic map(
    f_WIDTH => WIDTH,
    f_DEPTH => DEPTH,
    CLKS_PER_BIT => CLKS_PER_BIT
)
port map(

    clk   => clk,
    rst   => rst,

    write => write,
    data_write => data_write,

    tx_serial => tx_serial,

    fifo_full => fifo_full,
    fifo_empty => fifo_empty

);


-- clock generator


clk_process : process
begin
    while true loop
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end loop;
end process;



-- main stimulus


stim_proc : process
begin



rst <= '1';
wait for 50 ns;

-- ASSERT: FIFO should be empty during reset
assert (fifo_empty = '1')
report "ERROR: FIFO not empty during RESET_SEQUENCE"
severity error;

rst <= '0';
wait for 100 ns;


for i in 0 to 60 loop

    write <= '1';
    data_write <= std_logic_vector(to_unsigned(i,WIDTH));

    wait for CLK_PERIOD;

    -- ASSERT: When FIFO is full, no further writes expected
    if fifo_full = '1' then
        assert (write = '1')
        report "WARNING: Writing attempted when FIFO is full RESET_SEQUENCE"
        severity error;
    end if;

end loop;

write <= '0';

wait for 200 ns;

-- ASSERT: FIFO should eventually become full
assert (fifo_full = '1')
report "ERROR: FIFO did not reach full condition RESET_SEQUENCE"
severity error;


wait for 500 ns;

-- ASSERT: FIFO should become empty after idle
assert (fifo_empty = '1')
report "ERROR: FIFO did not become empty"
severity error;


for i in 0 to 20 loop

    wait for CLK_PERIOD - 1 ns;

    write <= '1';
    data_write <= std_logic_vector(to_unsigned(i+100,WIDTH));

    wait for 1 ns;

    -- ASSERT: Check no illegal full + empty condition
    assert not (fifo_full = '1' and fifo_empty = '1')
    report "ERROR: FIFO full and empty simultaneously RESET_SEQUENCE"
    severity error;

end loop;

write <= '0';

wait for 200 ns;


for i in 0 to 30 loop

    wait for 4 ns;
    write <= not write;

    wait for 3 ns;
    write <= not write;

    -- ASSERT: No invalid FIFO state
    assert not (fifo_full = '1' and fifo_empty = '1')
    report "ERROR: Invalid FIFO state during RESET_SEQUENCE"
    severity error;

end loop;



wait for 500 ns;

        wait for 20 ns;
        report "Simulation completed." severity note;
        std.env.stop;



end process;


end tb;