----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 11:40:19 PM
-- Design Name: 
-- Module Name: reg_PISO_cgat_tb - Behavioral
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

entity reg_PISO_cgat_tb is
end reg_PISO_cgat_tb;

architecture Behavioral of reg_PISO_cgat_tb is

    constant n: natural := 8;

    signal T_I      : std_logic_vector(n-1 downto 0):= (others => '0');
    signal T_clock  : std_logic := '0';
    signal T_reset  : std_logic := '1';
    signal T_load   : std_logic := '0';
    signal T_Q      : std_logic_vector(n-1 downto 0);
    signal T_s_out  : std_logic;

    constant clk_period : time := 10 ns;

    signal bug_count : integer := 0;

begin

    DUT: entity work.reg_PISO_cgat
        generic map (n => n)
        port map(
            I      => T_I,
            clock  => T_clock,
            reset  => T_reset,
            load   => T_load,
            Q      => T_Q,
            s_out  => T_s_out
        );

    -- Clock generation
    clk_process : process
    begin
        --while true loop
            T_clock <= '0';
            wait for clk_period/2;
            T_clock <= '1';
            wait for clk_period/2;
        --end loop;
    end process;

   stim : process
begin
      -- RESET

    T_reset <= '1';
    wait for 20 ns;
    T_reset <= '0';

  -- LOAD DATA

    T_I <= "11000111";
    T_load <= '1';

    wait until rising_edge(T_clock);
    T_load <= '0';
    wait for 1 ns;

    -- Check load
    assert T_Q = "11000111"
    report "ERROR: Load failed :- CLOCK_GATTING"
    severity error;

 -- SHIFT CHECK

    for i in 0 to n-1 loop
        wait until rising_edge(T_clock);
        wait for 1 ns;

        -- Just check serial output (simple)
        assert T_s_out = T_Q(n-1)
        report "Shift error at cycle " & integer'image(i)
        severity error;
    end loop;

    -- END SIM

    report "Simulation completed successfully." severity note;
    wait for 50 ns;
    std.env.stop;

end process;

end Behavioral;
