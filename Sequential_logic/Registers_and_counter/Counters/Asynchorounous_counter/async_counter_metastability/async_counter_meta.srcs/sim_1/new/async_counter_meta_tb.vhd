----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 04:35:11 PM
-- Design Name: 
-- Module Name: async_counter_meta_tb - Behavioral
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

entity async_counter_meta_tb is
--  Port ( );
end async_counter_meta_tb;

architecture Behavioral of async_counter_meta_tb is


    constant n: natural :=4;

    signal T_clock : std_logic:= '0';
    signal T_reset : std_logic := '1';
    signal T_counter : unsigned(n-1 downto 0);
    signal rcount : integer := 0;
    signal bug_count : integer := 0;
    constant clk_period : time := 10 ns;
    

begin

dut : entity work.async_counter_meta

    port map (
               Clock => T_clock,
               reset => T_reset,
               counter => T_counter
               );
              

clk_process : process
begin
    while true loop
        T_clock <= '0';
        wait for clk_period/2;

        T_clock <= '1';
        wait for clk_period/2;
    end loop;
end process;


stimuli : process
begin
        wait for 30 ns; 
            T_reset <= '0';
            
       wait for 500 ns; 
            T_reset <= '1'; 
       wait for 50 ns;
            T_reset <= '0';   
        
wait for 100 ns;
std.env.stop;
end process;

-- MONITOR

process(T_clock)
begin


    if T_reset = '1' and T_counter /= 0  then
        bug_count <= bug_count + 1;
        assert false
        report "BUG DETECTED : METASTABILITY violation risk"
        severity ERROR;
    end if;


end process;

end Behavioral;
