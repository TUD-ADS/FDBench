----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 06:12:12 PM
-- Design Name: 
-- Module Name: lifo_rseq_tb - Behavioral
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

entity lifo_rseq_tb is
--  Port ( );
end lifo_rseq_tb;

architecture Behavioral of lifo_rseq_tb is



constant WIDTH : integer := 8;
constant DEPTH : integer := 16;

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

DUT : entity work.lifo_rseq
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
   -- while true loop
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   -- end loop;
end process;

clk_process2 : process
begin
    --while true loop
        clk2 <= '0';
        wait for clk_period2/2;
        clk2 <= '1';
        wait for clk_period2/2;
    --end loop;
end process;

-- STIMULUS PROCESS

stim_proc : process
begin

     -- RELEASE RESET
    wait for 20 ns;
    rst <= '0';

   -- NORMAL OPERATION
    for i in 0 to 5 loop
        write <= '1';
        data_in <= std_logic_vector(to_unsigned(i,WIDTH));
        wait for clk_period;
    end loop;

    write <= '0';
    wait for 20 ns;

 -- OVERFLOW BUG
    for i in 0 to DEPTH+4 loop
        write <= '1';
        data_in <= std_logic_vector(to_unsigned(i,WIDTH));
        injected_bugs <= injected_bugs + 1;
        wait for clk_period;
    end loop;

    write <= '0';
    wait for 20 ns;

    -- UNDERFLOW BUG
    read <= '1';
    for i in 0 to DEPTH+4 loop
        injected_bugs <= injected_bugs + 1;
        wait for clk_period;
    end loop;

    read <= '0';
    wait for 20 ns;

     -- RESET SEQUENCING BUG
    write <= '1';
    data_in <= x"AA";
    wait for clk_period;

    rst <= '1';
    injected_bugs <= injected_bugs + 1;
    wait for clk_period;

    rst <= '0';
    write <= '0';
    wait for 20 ns;

 -- METASTABILITY INJECTION
    for i in 0 to 10 loop
        wait for 3 ns;
        write <= not write;
        injected_bugs <= injected_bugs + 1;
    end loop;

    wait for 20 ns;

   -- CDC INJECTION
    for i in 0 to 10 loop
        wait until rising_edge(clk2);
        data_in <= std_logic_vector(to_unsigned(i,WIDTH));
        write <= '1';
        injected_bugs <= injected_bugs + 1;
    end loop;

    write <= '0';
    wait for 50 ns;

  -- SIMULATION END

    report "--------------------------------";
    report "TOTAL BUGS INJECTED = " & integer'image(injected_bugs);
    report "TOTAL BUGS DETECTED = " & integer'image(detected_bugs);
    report "--------------------------------";
    wait for 100 ns;
    std.env.stop;

end process;

-- ASSERTION MONITOR

monitor_proc : process(clk)
begin

if rising_edge(clk) then

   -- OVERFLOW
    if write='1' and full='1' then
        assert false
        report "BUG DETECTED : OVERFLOW_DETECTED"
        severity ERROR;
    end if;

     -- UNDERFLOW
    if read='1' and empty='1' then
        detected_bugs <= detected_bugs + 1;
        assert false
        report "BUG DETECTED : UNDERFLOW_DETECTED"
        severity ERROR;
    end if;

  
    -- RESET SEQUENCING

    if rst='1' and (write='1' or read='1') then
        detected_bugs <= detected_bugs + 1;
        assert false
        report "BUG DETECTED : RESET_SEQUENCE violation"
        severity ERROR;
    end if;

end if;
end process;




end Behavioral;
