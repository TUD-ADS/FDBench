----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 05:06:38 AM
-- Design Name: 
-- Module Name: f_fir_time - Behavioral
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

entity f_fir_time is

    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;

        -- input stream
        data_in    : in  std_logic_vector(15 downto 0);
        write      : in  std_logic;

        -- output
        data_out   : out std_logic_vector(31 downto 0);
        fifo_full  : out std_logic;
        fifo_empty : out std_logic
    );
end f_fir_time;

architecture Behavioral of f_fir_time is

   signal fifo_data_out : std_logic_vector(15 downto 0);
    signal fifo_read     : std_logic;
    
    signal fifo_empty_s  : std_logic;
    signal fifo_full_s   : std_logic;

begin

fifo_inst : entity work.fifo
        generic map (
            f_WIDTH => 16,
            f_DEPTH => 32
        )
        port map (
            syn_clock  => clk,
            syn_reset  => reset,
            write      => write,
            read       => fifo_read,
            data_write => data_in,
            data_read  => fifo_data_out,
            empty      => fifo_empty_s,
            full       => fifo_full_s
        );


        fir_inst : entity work.FIR_Filter
        port map (
            clk      => clk,
            reset    => reset,
            data_in  => fifo_data_out,
            data_out => data_out
        );


    fifo_read <= '1' when fifo_empty_s = '0' else '0';
    
fifo_empty <= fifo_empty_s;
fifo_full  <= fifo_full_s;


end Behavioral;
