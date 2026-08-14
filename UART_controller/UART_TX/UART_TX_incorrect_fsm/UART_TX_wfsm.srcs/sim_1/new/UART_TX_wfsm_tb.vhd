
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX_wfsm_tb  is
end UART_TX_wfsm_tb;

architecture behavior of UART_TX_wfsm_tb is


-- PARAMETERS


constant CLK_PERIOD : time := 10 ns;
constant CLKS_PER_BIT : integer := 868;


-- SIGNALS


signal clk       : std_logic := '0';
signal rst       : std_logic := '0';

signal tx_start  : std_logic := '0';
signal tx_data   : std_logic_vector(7 downto 0) := (others => '0');

signal tx_serial : std_logic;
signal tx_busy   : std_logic;
signal tx_done   : std_logic;

signal frame_count : integer := 0;


-- CLOCK GENERATION


begin

--clk <= not clk after CLK_PERIOD/2;


-- DUT


dut : entity work.UART_TX_wfsm
generic map(
    CLKS_PER_BIT => CLKS_PER_BIT
)
port map(
    clk       => clk,
    rst       => rst,
    tx_start  => tx_start,
    tx_data   => tx_data,
    tx_serial => tx_serial,
    tx_busy   => tx_busy,
    tx_done   => tx_done
);


clk_process : process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;

    clk <= '1';
    wait for CLK_PERIOD/2;
end process clk_process;

-- MAIN STIMULUS



stimulus : process
begin

    
    -- RESET
    

    rst <= '1';
    wait for 100 ns;
    rst <= '0';

    wait for 200 ns;

    
    -- TRANSMIT BYTE 1
    

    tx_data <= x"A5";
    tx_start <= '1';
    wait for CLK_PERIOD;
    tx_start <= '0';
    
    wait until rising_edge(clk);

    -- FSM ASSERT: must enter busy
    assert tx_busy = '1'
    report "ERROR:WRONG_TRANSITION_BUG"
    severity error;

    -- START BIT CHECK
    wait for CLK_PERIOD;
    assert tx_serial = '0'
    report "ERROR: WRONG_TRANSITION_BUG"
    severity error;

    wait until tx_done = '1';
    frame_count <= frame_count + 1;
   wait for 20 ns;

    report "Simulation completed successfully" severity note;
    std.env.stop;
   
end process;
end behavior;

