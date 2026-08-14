----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 01:03:54 AM
-- Design Name: 
-- Module Name: SPC_FSM_timing - Behavioral
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

entity SPC_FSM_timing is
Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        req      : in  std_logic;
        data_in  : in  std_logic_vector(7 downto 0);
        ready    : in  std_logic;
        ack      : out std_logic;
        busy     : out std_logic;
        done     : out std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
end SPC_FSM_timing;

architecture Behavioral of SPC_FSM_timing is



type state_type is (IDLE,SEND_ACK,TRANSFER,COMPLETE);
signal present_state,next_state:state_type;

signal comb:std_logic_vector(7 downto 0);

begin

process(clk,rst)
begin
if rst='1' then
present_state<=IDLE;
elsif rising_edge(clk) then
present_state<=next_state;
end if;
end process;

process(data_in)
begin
comb <= data_in xor data_in xor data_in xor data_in xor data_in; -- long path
end process;

process(present_state,req,ready)
begin

next_state<=present_state;

case present_state is

when IDLE =>
if req='1' then
next_state<=SEND_ACK;
end if;

when SEND_ACK =>
next_state<=TRANSFER;

when TRANSFER =>
if ready='1' then
next_state<=COMPLETE;
end if;

when COMPLETE =>
next_state<=IDLE;

end case;

end process;

process(present_state)
begin

ack<='0';
busy<='0';
done<='0';
data_out<=comb;

case present_state is

when SEND_ACK =>
ack<='1';
busy<='1';

when TRANSFER =>
busy<='1';

when COMPLETE =>
done<='1';

when others =>
null;

end case;

end process;



end Behavioral;
