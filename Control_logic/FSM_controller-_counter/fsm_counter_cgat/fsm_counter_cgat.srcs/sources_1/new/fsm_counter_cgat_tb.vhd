----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 11:40:58 AM
-- Design Name: 
-- Module Name: fsm_counter_cgat_tb - Behavioral
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

entity fsm_counter_cgat_tb is
--  Port ( );
end fsm_counter_cgat_tb;

architecture Behavioral of fsm_counter_cgat_tb is

    constant N : natural := 4;

    -- DUT signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal ready       : std_logic := '0';

    signal ack         : std_logic;
    signal busy        : std_logic;
    signal done        : std_logic;
    signal counter_out : unsigned(N-1 downto 0);
    signal data_out    : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

        ------------------------------------------------------------------
    -- DUT INSTANTIATION
    ------------------------------------------------------------------
    DUT : entity work.fsm_counter_cgat
        generic map (N => N)
        port map (
            clk         => clk,
            rst         => rst,
            ready       => ready,
            ack         => ack,
            busy        => busy,
            done        => done,
            counter_out => counter_out,
            data_out    => data_out
        );
        
            ------------------------------------------------------------------
    -- CLOCK GENERATION
    ------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;
    
        ------------------------------------------------------------------
    -- STIMULUS PROCESS
    ------------------------------------------------------------------
    stim_proc : process
    begin
        --------------------------------------------------------------
        -- TEST 1: RESET CHECK
        --------------------------------------------------------------
        rst <= '1';
        ready <= '0';
        wait for 30 ns;
        rst <= '0';
        wait for 20 ns;

        --------------------------------------------------------------
        -- TEST 2: NORMAL FLOW (ready = 1)
        --------------------------------------------------------------
        ready <= '1';
        wait for 200 ns;
        
               --------------------------------------------------------------
        -- TEST 3: STALL CONDITION (ready = 0)
        --------------------------------------------------------------
        ready <= '0';
        wait for 100 ns;

        -- Release stall
        ready <= '1';
        wait for 100 ns;

        --------------------------------------------------------------
        -- TEST 4: BACK-TO-BACK TRANSACTIONS
        --------------------------------------------------------------
        wait for 200 ns;

        --------------------------------------------------------------
        -- TEST 5: RANDOM READY TOGGLE (STRESS TEST)
        --------------------------------------------------------------
        for i in 0 to 20 loop
            ready <= counter_out(0) xor counter_out(1);
            wait for 20 ns;
        end loop;
        
                --------------------------------------------------------------
        -- TEST 6: COUNTER WRAP COVERAGE
        --------------------------------------------------------------
        wait for 300 ns;

        --------------------------------------------------------------
        -- END SIMULATION
        --------------------------------------------------------------
        wait;
    end process;
    
    ------------------------------------------------------------------
    -- MONITOR (SELF-CHECKING)
    ------------------------------------------------------------------
    monitor_proc : process(clk)
    begin
        if rising_edge(clk) then

            -- Check: reset condition
            if rst = '1' then
                assert counter_out = 0
                report "ERROR: CLOCK_GATTING reset properly"
                severity error;
            end if;

            -- Check: busy & ack relation
            if ack = '1' then
                assert busy = '1'
                report "ERROR: CLOCK_GATTING BUSY"
                severity error;
            end if;

            -- Check: done should not overlap with ack
            if done = '1' then
                assert ack = '0'
                report "ERROR: CLOCK_GATTING overlap"
                severity error;
                
                         end if;

        end if;
    end process;


end Behavioral;
