----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/11/2026 11:41:20 AM
-- Design Name: 
-- Module Name: f_fir_tb - Behavioral
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

entity f_fir_over_tb is
--  Port ( );
end f_fir_over_tb;

architecture Behavioral of f_fir_over_tb is

constant clk_period : time := 10 ns;


signal clk        : std_logic := '0';
signal reset      : std_logic := '1';
signal data_in    : std_logic_vector(15 downto 0) := (others => '0');
signal write      : std_logic := '0';
signal data_out   : std_logic_vector(31 downto 0);
signal fifo_full  : std_logic;
signal fifo_empty : std_logic;


begin


   dut : entity work.f_fir_over
        port map (
            clk        => clk,
            reset      => reset,
            data_in    => data_in,
            write      => write,
            data_out   => data_out,
            fifo_full  => fifo_full,
            fifo_empty => fifo_empty
        );
        
        
    clk_process : process
    begin
       
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
       
    end process;
    
    
      stimulus : process
        variable prev_data_out : std_logic_vector(31 downto 0);
        variable prev_data_in  : std_logic_vector(15 downto 0);
    begin

        
        -- RESET PHASE
        
        reset <= '1';
        write <= '0';

        wait until rising_edge(clk);

        wait for 50 ns;

        
        -- RESET RELEASE
        
        reset <= '0';
        wait until rising_edge(clk);
        
        -- WRITE PHASE
        
        write <= '1';

        for i in 0 to 30 loop

            prev_data_out := data_out;
            prev_data_in  := data_in;

            data_in <= std_logic_vector(to_signed(i * 100, 16));

            wait until rising_edge(clk);

            
            -- FIFO PROTOCOL ASSERTIONS
            
            assert not (write = '1' and fifo_full = '1')
                report "ERROR: OVERFLOW_DETECTED FIFO FULL"
                severity error;

        end loop;
        wait for 50 ns;

        write <= '0';
 wait for 500 ns;
        


        
        -- END SIMULATION
        
        report "Simulation completed successfully." severity note;
        std.env.stop;
    
    
    end process;   

end Behavioral;
