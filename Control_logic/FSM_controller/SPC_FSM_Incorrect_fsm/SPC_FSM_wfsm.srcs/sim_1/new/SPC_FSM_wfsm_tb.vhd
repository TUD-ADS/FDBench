----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 01:32:31 AM
-- Design Name: 
-- Module Name: SPC_FSM_wfsm_tb - Behavioral
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

entity SPC_FSM_wfsm_tb  is
end SPC_FSM_wfsm_tb;

architecture Behavioral of SPC_FSM_wfsm_tb is

    ----------------------------------------------------------------
    -- DUT Signals
    ----------------------------------------------------------------
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';

    signal req      : std_logic := '0';
    signal ready    : std_logic := '0';

    signal data_in  : std_logic_vector(7 downto 0) := (others=>'0');
    signal data_out : std_logic_vector(7 downto 0);

    signal ack      : std_logic;
    signal busy     : std_logic;
    signal done     : std_logic;

-- Clock period

    constant CLK_PERIOD : time := 10 ns;

   -- Component Declaration

    component SPC_FSM_wfsm
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic;

            req      : in  std_logic;
            data_in  : in  std_logic_vector(7 downto 0);
            ready    : in  std_logic;

            ack      : out std_logic;
            busy     : out std_logic;
            done     : out std_logic;
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

begin

   -- DUT Instantiation

    DUT : SPC_FSM_wfsm
    port map(
        clk      => clk,
        rst      => rst,
        req      => req,
        data_in  => data_in,
        ready    => ready,
        ack      => ack,
        busy     => busy,
        done     => done,
        data_out => data_out
    );

 -- Clock Generator

    clk_process : process
    begin
        
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
       
    end process;

   -- Reset Generator
    reset_process : process
    begin
        rst <= '1';
        wait for 30 ns;
        rst <= '0';
        wait;
    end process;

   -- Stimulus Process

    stimulus : process
    begin

        wait for 40 ns;

 -- Transaction 1

        data_in <= "10101010";
        req <= '1';

        wait for CLK_PERIOD;
        req <= '0';

        wait for 40 ns;

        ready <= '1';
        wait for CLK_PERIOD;
        ready <= '0';

        wait for 50 ns;

   -- Transaction 2

        data_in <= "11001100";
        req <= '1';

        wait for CLK_PERIOD;
        req <= '0';

        wait for 40 ns;

        ready <= '1';
        wait for CLK_PERIOD;
        ready <= '0';

        wait for 100 ns;

        -- Finish Simulation

        report "Simulation completed successfully." severity note;
    wait for 50 ns;
    std.env.stop;

    end process;

    ----------------------------------------------------------------
    -- Monitor Process
    ----------------------------------------------------------------
    monitor : process(clk)
    begin
        if rising_edge(clk) then

            if ack='1' then
                  assert false
                report "BUG: wrong_transition_bug"
                severity ERROR;
            end if;

            if busy='1' then
                report "FSM Busy";
            end if;

            if done='1' then
                report "Transaction Done. Data Out = "
                & integer'image(to_integer(unsigned(data_out)));
            end if;

        end if;
    end process;

end Behavioral;