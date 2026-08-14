----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 03:41:39 AM
-- Design Name: 
-- Module Name: FIR_Filter_cga_tb - Behavioral
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

entity FIR_Filter_cga_tb is
--  Port ( );
end FIR_Filter_cga_tb;

architecture Behavioral of FIR_Filter_cga_tb is

   -- ================= CONSTANTS =================
    constant CLK_PERIOD      : time := 10 ns;
    constant PIPELINE_DELAY  : integer := 7;
    constant IMPULSE_VALUE   : integer := 1000;

    -- FIR coefficients (same as DUT)
    type int_array_t is array (0 to 31) of integer;
    constant COEFFS : int_array_t := (
        -17,-20,-26,-31,-29,-15,20,82,174,294,437,591,741,873,971,1023,
        1023,971,873,741,591,437,294,174,82,20,-15,-29,-31,-26,-20,-17
    );

    -- ================= SIGNALS =================
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal data_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal data_out : std_logic_vector(31 downto 0);

    -- Scoreboard
    signal cycle_cnt : integer := 0;

begin

    -- ================= CLOCK =================
    clk <= not clk after CLK_PERIOD / 2;

    -- ================= DUT =================
    DUT : entity work.FIR_Filter_cgat
        port map (
            clk      => clk,
            reset    => reset,
            data_in  => data_in,
            data_out => data_out
        );

    -- ================= CYCLE COUNTER =================
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

   process
begin
    -- RESET
    wait for 3 * CLK_PERIOD;
    reset <= '0';

    
    -- 1. IMPULSE
    
    data_in <= std_logic_vector(to_signed(1000,16));
    wait for CLK_PERIOD;
    data_in <= (others => '0');
    wait for 200 ns;

    
    -- 2. STEP INPUT
    
    data_in <= std_logic_vector(to_signed(2000,16));
    wait for 100 ns;

    
    -- 3. RAMP
    
    for i in 0 to 20 loop
        data_in <= std_logic_vector(to_signed(i*100,16));
        wait for CLK_PERIOD;
    end loop;

    
    -- 4. ALTERNATING
    
    for i in 0 to 20 loop
        if (i mod 2 = 0) then
            data_in <= x"7FFF";
        else
            data_in <= x"8000";
        end if;
        wait for CLK_PERIOD;
    end loop;

    
    -- 5. RANDOM-LIKE
    
    data_in <= x"1234"; wait for CLK_PERIOD;
    data_in <= x"5678"; wait for CLK_PERIOD;
    data_in <= x"9ABC"; wait for CLK_PERIOD;
    data_in <= x"DEF0"; wait for CLK_PERIOD;

    
    -- 6. ZERO
    
    data_in <= (others => '0');
    wait for 100 ns;

    
    -- END
    
    assert false
        report "SIMULATION COMPLETE ?"
        severity note;

          wait for 20 ns;
        report "Simulation completed." severity note;
        std.env.stop;
end process;

    -- ================= ASSERTIONS =================
    process(clk)
        variable expected : integer;
        variable actual   : integer;
    begin
        if rising_edge(clk) then
            if reset = '0' then

                actual := to_integer(signed(data_out));

                -- 1?? Output must be zero during pipeline latency
                if cycle_cnt < PIPELINE_DELAY then
                    assert actual = 0
                        report "CLOCK_GATTING"
                        severity error;
                end if;

                -- 2?? Impulse response check
                if cycle_cnt >= PIPELINE_DELAY and
                   cycle_cnt < PIPELINE_DELAY + 32 then

                    expected := COEFFS(cycle_cnt - PIPELINE_DELAY)
                                * IMPULSE_VALUE;

                    assert actual = expected
                        report "CLOCK_GATTING"
                               & integer'image(cycle_cnt - PIPELINE_DELAY)
                        severity error;
                end if;

                -- 3?? Output must return to zero after response
                if cycle_cnt >= PIPELINE_DELAY + 32 then
                    assert actual = 0
                        report "CLOCK_GATTING"
                        severity error;
                end if;

            end if;
        end if;
    end process;



end Behavioral;
