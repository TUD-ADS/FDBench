
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX_meta_tb  is
end UART_TX_meta_tb;

architecture behavior of UART_TX_meta_tb is


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


dut : entity work.UART_TX_meta
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
       
    end process;

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

    wait until tx_done = '1';
    frame_count <= frame_count + 1;

    
    -- TRANSMIT BYTE 2
    

    wait for 2 us;

    tx_data <= x"3C";
    tx_start <= '1';
    wait for CLK_PERIOD;
    tx_start <= '0';

    wait until tx_done = '1';
    frame_count <= frame_count + 1;

    
    -- OVERFLOW TEST
    

    wait for 5 us;

    tx_data <= x"AA";
    tx_start <= '1';
    wait for CLK_PERIOD;
    tx_start <= '0';

    wait for 20 ns;

    -- Start again while busy
    tx_data <= x"55";
    tx_start <= '1';
    wait for CLK_PERIOD;
    tx_start <= '0';

    wait until tx_done='1';

    
    -- RESET DURING TRANSMISSION
    

    wait for 5 us;

    tx_data <= x"F0";
    tx_start <= '1';
    wait for CLK_PERIOD;
    tx_start <= '0';

    wait for 3 us;

    rst <= '1';
    wait for 100 ns;
    rst <= '0';

   
    -- GLITCH TEST (metastability-like stimulus)
    

    wait for 5 us;

    tx_data <= x"77";

    tx_start <= '1';
    wait for 2 ns;
    tx_start <= '0';
    wait for 3 ns;
    tx_start <= '1';
    wait for 1 ns;
    tx_start <= '0';

    wait;

end process;


-- WATCHDOG (Detect stuck FSM)


watchdog : process(clk)

variable timeout : integer := 0;

begin

if rising_edge(clk) then

    if tx_busy='1' then
        timeout := timeout + 1;
    else
        timeout := 0;
    end if;

    if timeout > 20000 then
        assert false
        report "ERROR: UART FSM STUCK"
        severity failure;
    end if;

end if;

end process;

end behavior;

