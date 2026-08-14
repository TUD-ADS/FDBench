library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity f_uart_tb is
end f_uart_tb;

architecture tb of f_uart_tb is


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

DUT : entity work.f_uart
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


-- RESET TEST




rst <= '1';
wait for 50 ns;

rst <= '0';
wait for 100 ns;


-- FIFO OVERFLOW TEST




for i in 0 to 60 loop

    write <= '1';
    data_write <= std_logic_vector(to_unsigned(i,WIDTH));

    wait for CLK_PERIOD;

end loop;

write <= '0';

wait for 200 ns;


-- FIFO UNDERFLOW TEST




wait for 500 ns;


-- TIMING VIOLATION TEST
-- change input close to clock edge




for i in 0 to 20 loop

    wait for CLK_PERIOD - 1 ns;

    write <= '1';
    data_write <= std_logic_vector(to_unsigned(i+100,WIDTH));

    wait for 1 ns;

end loop;

write <= '0';

wait for 200 ns;


-- METASTABILITY TEST
-- toggle near clock edge randomly




for i in 0 to 30 loop

    wait for 4 ns;
    write <= not write;

    wait for 3 ns;
    write <= not write;

end loop;

wait for 200 ns;


-- CDC TEST
-- asynchronous stimulus




for i in 0 to 20 loop

    wait for 7 ns;

    write <= '1';
    data_write <= std_logic_vector(to_unsigned(i+200,WIDTH));

    wait for 13 ns;

    write <= '0';

end loop;

wait for 300 ns;


-- WRONG FSM STRESS




for i in 0 to 10 loop

    write <= '1';
    data_write <= x"AA";

    wait for CLK_PERIOD;

    write <= '0';

    wait for 2*CLK_PERIOD;

end loop;

wait for 300 ns;


-- CLOCK GATING TEST




for i in 0 to 20 loop

    wait for CLK_PERIOD;

    if i mod 3 = 0 then
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
    end if;

end loop;

wait for 300 ns;


-- STUCK STATE TEST




for i in 0 to 20 loop

    write <= '1';
    data_write <= x"FF";

    wait for CLK_PERIOD;

end loop;

write <= '0';

wait for 500 ns;


-- END


        wait for 20 ns;
        report "Simulation completed." severity note;
        std.env.stop;


end process;

end tb;