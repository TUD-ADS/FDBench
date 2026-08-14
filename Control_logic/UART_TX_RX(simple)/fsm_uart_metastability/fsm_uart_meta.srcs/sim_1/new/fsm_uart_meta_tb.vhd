----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/17/2026 04:36:48 PM
-- Design Name: 
-- Module Name: fsm_uart_meta_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm_uart_meta_tb is
--  Port ( );
end fsm_uart_meta_tb;

architecture Behavioral of fsm_uart_meta_tb is

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    constant clk_period : time := 10 ns;

    signal tx_start : std_logic := '0';
    signal tx_data  : std_logic_vector(7 downto 0) := x"A5";

    signal rx       : std_logic := '1';

    -- DUT outputs
    signal tx_m, tx_cg, tx_fsm : std_logic;
    signal busy_m, busy_cg, busy_fsm : std_logic;
    signal done_m, done_cg, done_fsm : std_logic;

    -- Monitor counters
    signal cycle_cnt : integer := 0;

    -- Bug detection flags
    signal fsm_stuck_flag : std_logic := '0';
    signal cg_no_toggle   : std_logic := '0';
begin


 -- DUT INSTANCES

    DUT_META : entity work.fsm_uart_meta
        port map (
            baud_clk => clk,
            reset    => reset,
            tx_start => tx_start,
            tx_data  => tx_data,
            tx_busy  => busy_m,
            tx       => tx_m,
            rx       => rx,
            rx_data  => open,
            rx_done  => done_m
        );


    -- CLOCK
    
    clk_process : process
    begin
        --while true loop
        CLK <= '0';
        wait for clk_period/2;
        CLK <= '1';
        wait for clk_period/2;
    --end loop;
    end process;

 -- STIMULUS

  process
begin
    -- initial values
    reset    <= '1';
    tx_start <= '0';

    -- wait 5 clock cycles
    wait for 5 * CLK_PERIOD;
    reset <= '0';

    -- wait until cycle 10 (5 more cycles)
    wait for 5 * CLK_PERIOD;
    tx_start <= '1';

    -- wait until cycle 12 (2 more cycles)
    wait for 2 * CLK_PERIOD;
    tx_start <= '0';

    -- stop process
wait for 50 ns;
      report "Simulation completed successfully." severity note;
    
    std.env.stop;
end process;
     
  -- MONITOR PROCESS (NO WAIT)

    monitor_proc : process(clk)
        variable prev_tx_fsm : std_logic := '1';
        variable toggle_cnt  : integer := 0;
        variable fsm_busy_cycles : integer := 0;
    begin
        if rising_edge(clk) then

         -- PRINT BASIC SIGNALS

            report "Cycle=" & integer'image(cycle_cnt) &
                   " | FSM_TX=" & std_logic'image(tx_fsm) &
                   " | CG_TX=" & std_logic'image(tx_cg) &
                   " | META_TX=" & std_logic'image(tx_m);

            -- 1?? DETECT FSM STUCK BUG

            if busy_fsm = '1' then
                fsm_busy_cycles := fsm_busy_cycles + 1;
            else
                fsm_busy_cycles := 0;
                            end if;

            if fsm_busy_cycles > 20 then
                fsm_stuck_flag <= '1';
                report "? BUG DETECTED: FSM stuck in DATA state"
                    severity error;
            end if;

               -- 2?? DETECT CLOCK GATING ISSUE

            if tx_cg /= prev_tx_fsm then
                toggle_cnt := toggle_cnt + 1;
            end if;

            if cycle_cnt > 30 and toggle_cnt < 3 then
                cg_no_toggle <= '1';
                report "BUG DETECTED: Clock gating ? no proper toggling"
                    severity error;
            end if;

      -- UPDATE PREVIOUS VALUES

            prev_tx_fsm := tx_fsm;

        end if;
    end process;


        
end Behavioral;
