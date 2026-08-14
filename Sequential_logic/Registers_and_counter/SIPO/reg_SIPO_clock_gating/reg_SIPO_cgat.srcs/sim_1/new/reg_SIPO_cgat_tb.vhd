----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/10/2025 12:38:59 PM
-- Design Name: 
-- Module Name: reg_SIPO_tb - Behavioral
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

entity reg_SIPO_cgat_tb is
--  Port ( );
end reg_SIPO_cgat_tb;

architecture Behavioral of reg_SIPO_cgat_tb is
    constant n: natural := 8;
    signal T_I: std_logic;
    signal T_clock: std_logic := '0';
    signal T_reset: std_logic := '0';
    signal T_load : std_logic := '0';
    signal T_Q    : std_logic_vector(n-1 downto 0);
    
    constant clk_period : time := 10 ns;
    
begin

    DUT: entity work.reg_SIPO_cgat
    generic map (n=>n)
    port map (
                I => T_I,
                clock => T_clock,
                reset => T_reset,
                load => T_load,
                Q => T_Q
                );
                
    clk_process : process
    begin
        T_clock <= '0';
        wait for clk_period/2;
        T_clock <= '1';
        wait for clk_period/2;
    
    end process;
    
  stim : process
begin
    -- Reset
    T_reset <= '1';
    T_load  <= '0';
    T_I     <= '0';
    wait for 20 ns;

    assert T_Q = "00000000"
        report "RESET FAILED: METASTABILITY"
        severity error;

    -- Enable shifting
    T_reset <= '0';
    T_load  <= '1';

    wait until rising_edge(T_clock);
    -- Shift in 10101010 (MSB first example)
    T_I <= '1'; wait until rising_edge(T_clock);
    T_I <= '0'; wait until rising_edge(T_clock);
    T_I <= '1'; wait until rising_edge(T_clock);
    T_I <= '0'; wait until rising_edge(T_clock);
    T_I <= '1'; wait until rising_edge(T_clock);
    T_I <= '0'; wait until rising_edge(T_clock);
    T_I <= '1'; wait until rising_edge(T_clock);
    T_I <= '0'; wait until rising_edge(T_clock);

        assert T_Q = x"55"
        report "SIPO SHIFT FAILED : CLOCK_GATTING"
        severity error;
        

    T_load <= '0';
    T_I <= '1'; wait until rising_edge(T_clock);

        assert T_Q = x"AA"
        report "HOLD FAILED: CLOCK_GATTING"
        severity error;
        
wait for 10 ns;
            -- Hold test
  
    T_load <= '1';
 T_I    <= '0';wait until rising_edge(T_clock);
 

    assert T_Q = x"AA"
        report "HOLD FAILED: CLOCK_GATTING"
        severity error;
       wait until rising_edge(T_clock);
        T_load <= '0'; 
       wait for 10 ns;    

    report "Simulation completed successfully." severity note;
    wait for 50 ns;
    std.env.stop;
end process;

    

end Behavioral;
