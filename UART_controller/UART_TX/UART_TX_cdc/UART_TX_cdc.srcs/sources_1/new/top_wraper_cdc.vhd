----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2026 03:46:19 AM
-- Design Name: 
-- Module Name: top_wraper_cdc - Behavioral
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

entity top_wraper_cdc is
Port (         clk_in : in std_logic;
               rst_in : in std_logic);
end top_wraper_cdc;

architecture Behavioral of top_wraper_cdc is


component ila_0
  port (
    clk    : in std_logic;
    probe0 : in std_logic_vector(0 downto 0); --vector
    probe1 : in std_logic_vector(0 downto 0);
    probe2 : in std_logic_vector(0 downto 0);
    probe3 : in std_logic_vector(7 downto 0);

    probe4 : in std_logic_vector(0 downto 0);
    probe5 : in std_logic_vector(0 downto 0);
    probe6 : in std_logic_vector(0 downto 0);
    probe7 : in std_logic_vector(0 downto 0);
    probe8 : in std_logic_vector(0 downto 0);
    probe9 : in std_logic_vector(0 downto 0);
    probe10 : in std_logic_vector(0 downto 0);
    probe11 : in std_logic_vector(0 downto 0)
  );
end component;

 
 signal data_in  :  std_logic_vector(7 downto 0);
 signal start    :  std_logic;

signal  serial    :  std_logic;
signal  busy     :  std_logic;
signal  done     :  std_logic;

signal  serial_bug      :  std_logic;
signal  busy_bug     :  std_logic;
signal  done_bug     :  std_logic;

signal  error_serial      :  std_logic;
signal  error_busy     :  std_logic;
signal  error_done     :  std_logic;

--signal  error_bug     :  std_logic;
--signal  data_out_golden :  std_logic_vector(7 downto 0);
--signal  data_out_buggy :  std_logic_vector(7 downto 0);
signal counter : unsigned(7 downto 0) := (others => '0');


begin

process(clk_in)
begin
    if rising_edge(clk_in) then
        counter <= counter + 1;
        data_in <= std_logic_vector(counter);
        start <= counter(3);
   
    end if;
end process;

UART_TX_inst : entity work.UART_TX
    generic map(
    CLKS_PER_BIT => 868
)
port map(
    clk       => clk_in,
    rst       => rst_in,

    tx_start  => start,
    tx_data   => data_in,

    tx_serial => serial,
    tx_busy   => busy,
    tx_done   => done
    
    );
    
    
UART_TX_inst_cdc : entity work.UART_TX_cdc
    generic map(
    CLKS_PER_BIT => 868
)
port map(
    clk       => clk_in,
    rst       => rst_in,

    tx_start  => start,
    tx_data   => data_in,

    tx_serial => serial_bug,
    tx_busy   => busy_bug,
    tx_done   => done_bug
    
    );
    
--error_bug <= '1' when data_out_golden /= data_out_buggy else '0';
error_busy <= '1' when busy /= busy_bug else '0';
error_done <= '1' when done_bug /= done else '0';
error_serial <= '1' when serial /= serial_bug else '0';



ila_inst : ila_0
port map(
    clk       => clk_in,
    probe0(0) => start,
    probe1(0) => done,
    probe2(0) => serial,
    probe3 => data_in,
    probe4(0)    => busy,

    probe5(0) => rst_in,
    probe6(0)    => error_serial,
    probe7(0) => error_busy,
    probe8(0) => error_done,
    probe9(0) => done_bug,
    probe10(0) => serial_bug,
    probe11(0) => busy_bug
);



end Behavioral;
