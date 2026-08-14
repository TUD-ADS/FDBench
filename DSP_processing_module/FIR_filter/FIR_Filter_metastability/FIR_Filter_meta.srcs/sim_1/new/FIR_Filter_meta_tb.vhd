----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 03:40:21 AM
-- Design Name: 
-- Module Name: FIR_Filter_meta_tb - Behavioral
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

entity FIR_Filter_meta_tb is
end FIR_Filter_meta_tb;

architecture sim of FIR_Filter_meta_tb is

    -- =========================================================
    -- CONSTANTS
    -- =========================================================
    constant CLK_PERIOD : time := 10 ns;
    constant TAPS       : integer := 32;

    -- FIR coefficients (same as DUT)
    type int_array_t is array (0 to TAPS-1) of integer;
    constant COEFFS : int_array_t := (
        -17,-20,-26,-31,-29,-15,20,82,174,294,437,591,741,873,971,1023,
        1023,971,873,741,591,437,294,174,82,20,-15,-29,-31,-26,-20,-17
    );

    -- =========================================================
    -- SIGNALS
    -- =========================================================
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal data_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal data_out : std_logic_vector(31 downto 0);

    -- GOLDEN MODEL
    type delay_array_t is array (0 to TAPS-1) of integer;
    signal delay_line : delay_array_t := (others => 0);

    signal expected_out : integer := 0;

    signal cycle_cnt : integer := 0;

begin

    -- =========================================================
    -- CLOCK
    -- =========================================================
    clk <= not clk after CLK_PERIOD/2;

    -- =========================================================
    -- DUT
    -- =========================================================
    DUT : entity work.FIR_Filter_meta
        port map (
            clk      => clk,
            reset    => reset,
            data_in  => data_in,
            data_out => data_out
        );

    -- =========================================================
    -- CYCLE COUNTER
    -- =========================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cycle_cnt <= 0;
            else
                cycle_cnt <= cycle_cnt + 1;
            end if;
        end if;
    end process;

    -- =========================================================
    -- GOLDEN MODEL (REFERENCE FIR)
    -- =========================================================
    process(clk)
        variable acc : integer;
    begin
        if rising_edge(clk) then

            if reset = '1' then
                delay_line   <= (others => 0);
                expected_out <= 0;

            else
                -- shift delay line
                for i in TAPS-1 downto 1 loop
                    delay_line(i) <= delay_line(i-1);
                end loop;

                delay_line(0) <= to_integer(signed(data_in));

                -- MAC operation
                acc := 0;
                for i in 0 to TAPS-1 loop
                    acc := acc + delay_line(i) * COEFFS(i);
                end loop;

                expected_out <= acc;
            end if;
        end if;
    end process;

    -- =========================================================
    -- STIMULUS
    -- =========================================================
    process
    begin
        -- RESET
        wait for 3 * CLK_PERIOD;
        reset <= '0';

        --------------------------------------------------------
        -- 1. IMPULSE
        --------------------------------------------------------
        data_in <= std_logic_vector(to_signed(1000,16));
        wait for CLK_PERIOD;
        data_in <= (others => '0');
        wait for 200 ns;

        --------------------------------------------------------
        -- 2. STEP INPUT
        --------------------------------------------------------
        data_in <= std_logic_vector(to_signed(2000,16));
        wait for 100 ns;

        --------------------------------------------------------
        -- 3. RAMP
        --------------------------------------------------------
        for i in 0 to 20 loop
            data_in <= std_logic_vector(to_signed(i*100,16));
            wait for CLK_PERIOD;
        end loop;

        --------------------------------------------------------
        -- 4. ALTERNATING
        --------------------------------------------------------
        for i in 0 to 20 loop
            if (i mod 2 = 0) then
                data_in <= x"7FFF";
            else
                data_in <= x"8000";
            end if;
            wait for CLK_PERIOD;
        end loop;

        --------------------------------------------------------
        -- 5. RANDOM-LIKE
        --------------------------------------------------------
        data_in <= x"1234"; wait for CLK_PERIOD;
        data_in <= x"5678"; wait for CLK_PERIOD;
        data_in <= x"9ABC"; wait for CLK_PERIOD;
        data_in <= x"DEF0"; wait for CLK_PERIOD;

        --------------------------------------------------------
        -- 6. ZERO
        --------------------------------------------------------
        data_in <= (others => '0');
        wait for 200 ns;

        --------------------------------------------------------
        -- END
        --------------------------------------------------------
        report "Simulation completed successfully." severity note;
        std.env.stop;

    end process;

    -- =========================================================
    -- ASSERTIONS (SELF-CHECKING)
    -- =========================================================
    process(clk)
        variable actual : integer;
    begin
        if rising_edge(clk) then
            if reset = '0' then

                actual := to_integer(signed(data_out));

                -- MAIN CHECK
                assert actual = expected_out
                report "ERROR:METASTABILITY"
                       & integer'image(expected_out)
                       & " Actual="
                       & integer'image(actual)
                severity error;

            end if;
        end if;
    end process;

end sim;
  
