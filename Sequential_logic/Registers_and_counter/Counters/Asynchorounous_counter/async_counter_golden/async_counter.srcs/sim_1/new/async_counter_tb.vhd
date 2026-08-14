----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 04:29:08 AM
-- Design Name: 
-- Module Name: async_counter_tb - Behavioral
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

entity async_counter_tb is
--  Port ( );
end async_counter_tb;

architecture Behavioral of async_counter_tb is


    constant n: natural :=4;

    signal T_clock : std_logic:= '0';
    signal T_reset : std_logic := '1';
    signal T_counter : unsigned(n-1 downto 0);
    signal rcount : integer := 0;
    constant clk_period : time := 10 ns;

begin

dut : entity work.async_counter

    port map (
               Clock => T_clock,
               reset => T_reset,
               counter => T_counter
               );
              

    clk_process : process
    begin
        T_clock <= '0';
        wait for clk_period/2;
        T_clock <= '1';
        wait for clk_period/2;
    
    end process;
    
stimuli : process (T_clock)
begin
        rcount <= rcount + 1;
        if rcount = 10 then
            T_reset <= '0';
        elsif rcount = 50 then
            T_reset <= '1'; 
        elsif rcount = 58 then
            T_reset <= '0';   
        end if;

end process;
end Behavioral;
