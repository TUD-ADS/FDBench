----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2025 12:14:29 PM
-- Design Name: 
-- Module Name: fifo_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo_tb is
--  Port ( );
end fifo_tb;

architecture Behavioral of fifo_tb is


    constant T_WIDTH : natural :=8;
    constant T_DEPTH : integer :=32;
    
    signal T_syn_clock, T_syn_reset, T_write, T_read : std_logic :='0';
    signal T_full, T_empty : std_logic;
    signal T_data_write :  std_logic_vector(T_WIDTH-1 downto 0):= X"A5"; 
    signal T_data_read  :  std_logic_vector(T_WIDTH-1 downto 0);
    
    constant clk_period : time := 10 ns;
   
    

begin

    DUT : entity work.fifo
        generic map (
            f_WIDTH => T_WIDTH,
            f_DEPTH => T_DEPTH
        )
        port map (
            syn_clock  => T_syn_clock,
            syn_reset  => T_syn_reset,
            write      => T_write,
            read       => T_read,
            data_write => T_data_write,
            data_read  => T_data_read,
            empty      => T_empty,
            full       => T_full
        );



    clk_process : process
    begin
        T_syn_clock <= '0';
        wait for clk_period/2;
        T_syn_clock <= '1';
        wait for clk_period/2;
    
    end process;
    
    stim : process
    begin
    
      wait for 50 ns; 
 
      T_syn_reset <= '1';
         
      wait for 20 ns; 
         
      T_syn_reset <= '0';
      
      wait for 20 ns;
      
        report "PUSH 10";
        T_data_write <= x"0A";
        T_write <= '1';
        wait for 10 ns;
        T_write <= '0';
        wait for 10 ns;
        
        report "PUSH 20";
        T_data_write <= x"14";
        T_write <= '1';
        wait for 10 ns;
        T_write <= '0';
        wait for 10 ns;
        
        report "PUSH 30";
        T_data_write <= x"1E";
        T_write <= '1';
        wait for 10 ns;
        T_write <= '0';
        wait for 10 ns;
        
        report "POP (expect 10)";
        T_read <= '1';
        wait for 10 ns;
        T_read <= '0';
        wait for 10 ns;
        
        report "POP (expect 20)";
        T_read <= '1';
        wait for 10 ns;
        T_read <= '0';
        wait for 10 ns;
               
        wait for 50 ns;
        report "Simulation completed." severity note;
        std.env.stop; 
    
    
    end process;


end Behavioral;
