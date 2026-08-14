----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2026 03:58:05 PM
-- Design Name: 
-- Module Name: FIFO_RSEQ_tb - Behavioral
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

entity FIFO_RSEQ_tb is
end FIFO_RSEQ_tb;

architecture tb of FIFO_RSEQ_tb is

constant WIDTH : integer := 16;
constant DEPTH : integer := 32;

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal wr  : std_logic := '0';
signal rd  : std_logic := '0';

signal din  : std_logic_vector(WIDTH-1 downto 0);
signal dout : std_logic_vector(WIDTH-1 downto 0);

signal empty : std_logic;
signal full  : std_logic;

constant clk_period : time := 10 ns;

begin

    clk_process : process
    begin
        --while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        --end loop;
    end process;

DUT: entity work.FIFO_RSEQ
generic map(
    f_WIDTH => WIDTH,
    f_DEPTH => DEPTH
)
port map(
    syn_clock => clk,
    syn_reset => rst,
    write => wr,
    read  => rd,
    data_write => din,
    data_read  => dout,
    empty => empty,
    full  => full
);

stimulus: process
begin

wait for 20 ns;
rst <= '0';

-- write burst
for i in 0 to 20 loop
    wait until rising_edge(clk);
    wr <= '1';
    din <= std_logic_vector(to_unsigned(i, WIDTH));
end loop;

wr <= '0';

-- read burst
for i in 0 to 20 loop
    wait until rising_edge(clk);
    rd <= '1';
end loop;

rd <= '0';

    report "Simulation completed successfully." severity note;
    wait for 50 ns;
    std.env.stop;

end process;


-- ASSERTION + SCOREBOARD PROCESS
checker: process(clk)
begin
    if rising_edge(clk) then

      -- 1. Reset Check

        if rst = '1' then
            assert empty = '1'
            report "ERROR: FIFO not empty during RESET_SEQUENCE"
            severity error;
        end if;

       -- 2. No write when FULL

        if wr = '1' and full = '1' then
            assert false
            report "ERROR: Write attempted when FIFO is FULL OVERFLOW_DETECTED"
            severity error;
        end if;

       -- 3. No read when EMPTY
        if rd = '1' and empty = '1' then
            assert false
            report "ERROR: Read attempted when FIFO is EMPTY UNDERFLOW_DETECTED"
            severity error;
        end if;

        -- 4. Data integrity check (FIFO order)

        if rd = '1' and empty = '0' then
            assert false
            report "ERROR: Data mismatch in FIFO RESET_SEQUENCE"
            severity error;

        end if;

    end if;
end process;


end tb;