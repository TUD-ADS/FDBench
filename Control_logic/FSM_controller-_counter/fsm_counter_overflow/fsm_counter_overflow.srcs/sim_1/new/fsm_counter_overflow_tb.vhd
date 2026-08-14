----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 10:47:51 AM
-- Design Name: 
-- Module Name: fsm_counter_overflow_tb - Behavioral
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

entity fsm_counter_overflow_tb is
--  Port ( );
end fsm_counter_overflow_tb;

architecture Behavioral of fsm_counter_overflow_tb is

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

  -- DUT
    DUT : entity work.fsm_counter_overflow
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

   -- CLOCK

    clk_process : process
    begin
        --while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
       -- end loop;
    end process;

  -- STIMULUS + ASSERTIONS (NO MONITOR)

    stim_proc : process
    begin

 -- RESET TEST

        rst <= '1';
        ready <= '0';
        wait for CLK_PERIOD;

        -- ASSERT during reset
        assert counter_out = 0
        report "CLOCK_GATTING"
        severity error;

        wait for 20 ns;
        rst <= '0';
        wait for CLK_PERIOD;

  -- NORMAL FLOW

        ready <= '1';
        wait for 50 ns;

        -- ASSERT handshake
        if ack = '1' then
            assert busy = '1'
            report "CLOCK_GATTING"
            severity error;
        end if;

  -- STALL CONDITION

        ready <= '0';
        wait for 50 ns;

        -- ASSERT no progress during stall
        assert done = '0'
        report "CLOCK_GATTING"
        severity error;

        ready <= '1';
        wait for 100 ns;

   -- BACK-TO-BACK

        wait for 100 ns;

      -- RANDOM STRESS

        for i in 0 to 20 loop
            ready <= counter_out(0) xor counter_out(1);
            wait for 20 ns;

            -- ASSERT protocol correctness
            if done = '1' then
                assert ack = '0'
                report "CLOCK_GATTING"
                severity error;
            end if;
        end loop;

      -- COUNTER WRAP CHECK

        wait for 100 ns;

        -- Force check
        assert counter_out <= (2**N - 1)
        report "OVERFLOW_DETECTED"
        severity error;

-- FORCE ASSERT (DEBUG - remove later)

        assert false report "OVERFLOW_DETECTED" severity note;

       -- END

        wait for 20 ns;
        report "Simulation completed." severity note;
        std.env.stop;

    end process;

end Behavioral;
