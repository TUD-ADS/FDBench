----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 01:56:48 AM
-- Design Name: 
-- Module Name: UART_RX_cdc_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_RX_cdc_tb is
--  Port ( );
end UART_RX_cdc_tb;

architecture Behavioral of UART_RX_cdc_tb is


----------------------------------------------------
-- PARAMETERS
----------------------------------------------------
constant CLK_PERIOD   : time := 10 ns;
constant CLKS_PER_BIT : integer := 868;

----------------------------------------------------
-- SIGNALS
----------------------------------------------------
signal clk       : std_logic := '0';
signal rst       : std_logic := '0';

signal rx_serial : std_logic := '1';

signal rx_data   : std_logic_vector(7 downto 0);
signal rx_done   : std_logic;

signal frame_count : integer := 0;

----------------------------------------------------
-- TASK: SEND UART BYTE
----------------------------------------------------
procedure send_uart_byte (
    signal rx : out std_logic;
    data      : in  std_logic_vector(7 downto 0)
) is
begin

    -- START BIT
    rx <= '0';
    wait for CLKS_PER_BIT * CLK_PERIOD;

    -- DATA BITS (LSB first)
    for i in 0 to 7 loop
        rx <= data(i);
        wait for CLKS_PER_BIT * CLK_PERIOD;
    end loop;

    -- STOP BIT
    rx <= '1';
    wait for CLKS_PER_BIT * CLK_PERIOD;

end procedure;

begin

----------------------------------------------------
-- CLOCK
----------------------------------------------------

clk_process : process
begin
    while true loop
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end loop;
end process;


----------------------------------------------------
-- DUT
----------------------------------------------------
dut : entity work.UART_RX_cdc
generic map(
    CLKS_PER_BIT => CLKS_PER_BIT
)
port map(
    clk       => clk,
    rst       => rst,
    rx_serial => rx_serial,
    rx_data   => rx_data,
    rx_done   => rx_done
);




----------------------------------------------------
-- STIMULUS
----------------------------------------------------
stimulus : process
begin

    ------------------------------------------------
    -- RESET
    ------------------------------------------------
    rst <= '1';
    wait for 100 ns;
    rst <= '0';

    wait for 200 ns;

------------------------------------------------
    -- FRAME 1
    ------------------------------------------------
    send_uart_byte(rx_serial, x"A5");

    wait until rx_done = '1';
    assert rx_data = x"A5"
        report "ERROR: RX mismatch A5"
        severity error;

    frame_count <= frame_count + 1;

    ------------------------------------------------
    -- FRAME 2
    ------------------------------------------------
    wait for 2 us;

    send_uart_byte(rx_serial, x"3C");

    wait until rx_done = '1';
    assert rx_data = x"3C"
        report "ERROR: RX mismatch 3C"
        severity error;

    frame_count <= frame_count + 1;
 ------------------------------------------------
    -- BACK-TO-BACK FRAMES
    ------------------------------------------------
    wait for 2 us;

    send_uart_byte(rx_serial, x"AA");
    send_uart_byte(rx_serial, x"55");

    ------------------------------------------------
    -- RESET DURING FRAME
    ------------------------------------------------
    wait for 5 us;

    send_uart_byte(rx_serial, x"F0");

    wait for 3 us;

    rst <= '1';
    wait for 100 ns;
    rst <= '0';


    ------------------------------------------------
    -- END SIMULATION
    ------------------------------------------------
            wait for 20 ns;
    report "Simulation completed successfully" severity note;
    std.env.stop;
end process;

----------------------------------------------------------------
-- MONITOR + BUG COUNTER
----------------------------------------------------------------
monitor_proc : process(clk)

    variable prev_rx        : std_logic := '1';
    variable prev_done      : std_logic := '0';
    variable bit_timer      : integer := 0;
    variable frame_active   : boolean := false;

    variable bug_count      : integer := 0;

begin
    if rising_edge(clk) then

        --------------------------------------------------------
        -- TRACK FRAME START
        --------------------------------------------------------
        if (prev_rx = '1' and rx_serial = '0') then
            frame_active := true;
            bit_timer := 0;
        end if;

        --------------------------------------------------------
        -- COUNT BIT TIME
        --------------------------------------------------------
        if frame_active then
            bit_timer := bit_timer + 1;
        end if;

        --------------------------------------------------------
        -- BUG 1: GLITCH DETECTION (fast toggles)
        --------------------------------------------------------
        if (rx_serial /= prev_rx) then
            if bit_timer < (CLKS_PER_BIT / 4) then
                bug_count := bug_count + 1;
                report "CDC_BUG DETECTED"
                severity error;
            end if;
        end if;

        --------------------------------------------------------
        -- BUG 2: FALSE START BIT
        --------------------------------------------------------
        if frame_active and bit_timer = (CLKS_PER_BIT/2) then
            if rx_serial /= '0' then
                bug_count := bug_count + 1;
                report "BUG: FALSE START BIT"
                severity error;
            end if;
        end if;

        --------------------------------------------------------
        -- BUG 3: INVALID STOP BIT
        --------------------------------------------------------
        if frame_active and bit_timer = (CLKS_PER_BIT * 9) then
            if rx_serial /= '1' then
                bug_count := bug_count + 1;
                report "CDC_BUG STOP BIT"
                severity error;
            end if;
        end if;

        --------------------------------------------------------
        -- BUG 4: EARLY OR LATE DONE SIGNAL
        --------------------------------------------------------
        if (rx_done = '1' and prev_done = '0') then

            if bit_timer < (CLKS_PER_BIT * 9) then
                bug_count := bug_count + 1;
                report "BUG: EARLY RX_DONE"
                severity error;

            elsif bit_timer > (CLKS_PER_BIT * 11) then
                bug_count := bug_count + 1;
                report "BUG: LATE RX_DONE"
                severity erro;
            end if;

            frame_active := false;
        end if;

        --------------------------------------------------------
        -- BUG 5: DATA INSTABILITY CHECK
        --------------------------------------------------------
        if frame_active and (bit_timer mod CLKS_PER_BIT = 0) then
            if rx_serial /= prev_rx then
                bug_count := bug_count + 1;
                report "CDC_BUG DURING BIT"
                severity error;
            end if;
        end if;

        --------------------------------------------------------
        -- FINAL REPORT
        --------------------------------------------------------
        if bug_count > 0 and (bit_timer mod (CLKS_PER_BIT*12) = 0) then
            report "TOTAL BUG COUNT = " & integer'image(bug_count)
            severity note;
        end if;

        --------------------------------------------------------
        -- UPDATE PREVIOUS VALUES
        --------------------------------------------------------
        prev_rx   := rx_serial;
        prev_done := rx_done;

    end if;
end process;



end Behavioral;
