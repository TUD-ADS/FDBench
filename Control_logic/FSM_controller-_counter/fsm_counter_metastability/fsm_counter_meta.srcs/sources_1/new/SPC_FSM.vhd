----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 12:25:29 AM
-- Design Name: 
-- Module Name: SPC_FSM_meta - Behavioral
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

entity SPC_FSM is
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
end SPC_FSM;

architecture behaverioal of SPC_FSM is

    type state_type is (IDLE, SEND_ACK, TRANSFER, COMPLETE);
    signal present_state,next_state : state_type;

begin

process(clk,rst)
begin
    if rst='1' then
        present_state <= IDLE;
    elsif rising_edge(clk) then
        present_state <= next_state;
    end if;
end process;

-- async sampling of req (bug)
process(present_state,req,ready)
begin

    case present_state is

        when IDLE =>
            if req='1' then
                next_state <= SEND_ACK;
            else
                next_state <= IDLE;
            end if;

        when SEND_ACK =>
            next_state <= TRANSFER;

        when TRANSFER =>
            if ready='1' then
                next_state <= COMPLETE;
            else
                next_state <= TRANSFER;
            end if;

        when COMPLETE =>
            next_state <= IDLE;

    end case;

end process;

process(present_state,data_in)
begin

    ack<='0';
    busy<='0';
    done<='0';
    data_out<=(others=>'0');

    case present_state is

        when SEND_ACK =>
            ack<='1';
            busy<='1';

        when TRANSFER =>
            busy<='1';
            data_out<=data_in;

        when COMPLETE =>
            done<='1';

        when others =>
            null;

    end case;

end process;

end behaverioal;
