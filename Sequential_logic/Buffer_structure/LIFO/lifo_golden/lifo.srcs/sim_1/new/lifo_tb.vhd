----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 10:33:22 AM
-- Design Name: 
-- Module Name: lifo_tb - Behavioral
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

entity lifo_tb is
end lifo_tb;

architecture Behavioral of lifo_tb is

constant WIDTH : integer := 8;
constant DEPTH : integer := 32;

signal clk  : std_logic := '0';
signal clk2 : std_logic := '0';
signal rst  : std_logic := '1';

signal write : std_logic := '0';
signal read  : std_logic := '0';

signal data_in  : std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
signal data_out : std_logic_vector(WIDTH-1 downto 0);

signal empty : std_logic;
signal full  : std_logic;

signal injected_bugs : integer := 0;
signal detected_bugs : integer := 0;

constant clk_period  : time := 10 ns;
constant clk_period2 : time := 14 ns;

begin

-- DUT

DUT : entity work.lifo
generic map (
    g_WIDTH => WIDTH,
    g_DEPTH => DEPTH
)
port map (
    syn_clock  => clk,
    syn_reset  => rst,
    write      => write,
    read       => read,
    data_write => data_in,
    data_read  => data_out,
    empty      => empty,
    full       => full
);


-- CLOCK GENERATORS (FIXES X CLOCK ISSUE)

clk_process : process
begin
    while true loop
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end loop;
end process;


-- STIMULUS PROCESS
stim_proc : process
begin

 -- RESET (SYNC SAFE)
    rst <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst <= '0';

  -- WRITE 6 VALUES
    for i in 0 to 5 loop
        wait until rising_edge(clk);
        write   <= '1';
        data_in <= std_logic_vector(to_unsigned(i, WIDTH));
    end loop;

    wait until rising_edge(clk);
    write <= '0';

    -- READ 6 VALUES
    for i in 0 to 5 loop
        wait until rising_edge(clk);
        read <= '1';
    end loop;

    wait until rising_edge(clk);
    read <= '0';

 -- OVERFLOW TEST
    for i in 0 to DEPTH-1 loop
        wait until rising_edge(clk);
        write   <= '1';
        data_in <= std_logic_vector(to_unsigned(i, WIDTH));
    end loop;

    wait until rising_edge(clk);
    write <= '0';

    -- UNDERFLOW TEST
    for i in 0 to DEPTH-1 loop
        wait until rising_edge(clk);
        read <= '1';
    end loop;

    wait until rising_edge(clk);
    read <= '0';

   -- RESET DURING OPERATION
    wait until rising_edge(clk);
    write <= '1';
    data_in <= x"AA";

    wait until rising_edge(clk);
    rst <= '1';

    wait until rising_edge(clk);
    rst <= '0';
    write <= '0';

     -- END SIM
    wait for 50 ns;

    report "Simulation completed";
    std.env.stop;

end process;


-- ASSERTION MONITOR

monitor_proc : process(clk)
begin

if rising_edge(clk) then

     -- OVERFLOW

    if write='1' and full='1' then
        assert false
        report "BUG DETECTED : Overflow"
        severity ERROR;
    end if;

       -- UNDERFLOW

    if read='1' and empty='1' then
        detected_bugs <= detected_bugs + 1;
        assert false
        report "BUG DETECTED : Underflow"
        severity ERROR;
    end if;

   -- RESET SEQUENCING

    if rst='1' and (write='1' or read='1') and data_out /= (data_out'range => '0') then
        detected_bugs <= detected_bugs + 1;
        assert false
        report "BUG DETECTED : Reset sequencing violation"
        severity ERROR;
    end if;

end if;
end process;


end Behavioral;