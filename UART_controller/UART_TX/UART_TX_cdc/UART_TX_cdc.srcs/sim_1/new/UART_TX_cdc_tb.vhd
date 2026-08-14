----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 03:29:52 AM
-- Design Name: 
-- Module Name: UART_TX_cdc_tb - Behavioral
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

entity UART_TX_cdc_tb  is
end UART_TX_cdc_tb;

architecture behavior of UART_TX_cdc_tb is


-- PARAMETERS


constant CLK_PERIOD : time := 10 ns;
constant CLK_PERIOD1 : time := 16 ns;
constant CLKS_PER_BIT : integer := 868;


-- SIGNALS


signal clk       : std_logic := '0';
signal clk1       : std_logic := '0';
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


dut : entity work.UART_TX_cdc
generic map(
    CLKS_PER_BIT => CLKS_PER_BIT
)
port map(
    clk       => clk,
    clk1       => clk1,
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
       
    end process;
    
        clk_process1 : process
    begin
        
            clk1 <= '0';
            wait for CLK_PERIOD1/2;
            clk1 <= '1';
            wait for CLK_PERIOD1/2;
       
    end process;

-- MAIN STIMULUS


stimulus : process
variable last_tx : std_logic;
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

    --wait until tx_done = '1';
    frame_count <= frame_count + 1;

    wait for 5 us;

    tx_data <= x"77";

    tx_start <= '1';
    wait for 2 ns;
    tx_start <= '0';
    wait for 3 ns;
    tx_start <= '1';
    wait for 1 ns;
    tx_start <= '0';

    wait until rising_edge(clk);

    -- CDC ASSERTIONS

    -- no unknown values
    assert (tx_serial = '0' or tx_serial = '1')
    report "ERROR: tx_serial is X/U CDC_BUG"
    severity error;

    -- glitch detection
    last_tx := tx_serial;
    wait for CLK_PERIOD/2;

    assert tx_serial = last_tx
    report "ERROR: Glitch detected CDC_BUG"
    severity error;
    
        wait for 20 ns;
    report "Simulation completed successfully" severity note;
    std.env.stop;

end process;

end behavior;


