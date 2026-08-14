----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2026 03:14:52 AM
-- Design Name: 
-- Module Name: top_wraper_golden - Behavioral
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

entity top_wraper_golden is
Port (         clk_in : in std_logic;
               rst_in : in std_logic);
end top_wraper_golden;

architecture Behavioral of top_wraper_golden is

component ila_0
  port (
    clk    : in std_logic;
    probe0 : in std_logic_vector(0 downto 0); --vector
    probe1 : in std_logic_vector(0 downto 0);
    probe2 : in std_logic_vector(0 downto 0);
    probe3 : in std_logic_vector(7 downto 0);
    probe4 : in std_logic_vector(0 downto 0);
    probe5 : in std_logic_vector(0 downto 0)
  );
end component;

 
 signal data_in  :  std_logic_vector(7 downto 0);
 signal start    :  std_logic;

signal  serial    :  std_logic;
signal  busy     :  std_logic;
signal  done     :  std_logic;


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
    

ila_inst : ila_0
port map(
    clk       => clk_in,
    probe0(0) => start,
    probe1(0) => done,
    probe2(0) => serial,
    probe3    => data_in,
    probe4(0) => busy,
    probe5(0) => rst_in
);


end Behavioral;
