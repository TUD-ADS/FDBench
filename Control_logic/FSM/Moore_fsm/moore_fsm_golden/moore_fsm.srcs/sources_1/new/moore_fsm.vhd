----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2025 11:00:39 PM
-- Design Name: 
-- Module Name: fsm - Behavioral
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
-- 4 node FSM mealy state machine RTL design here
entity moore_fsm is
Port (  A: in std_logic_vector (1 downto 0);
        CLK: in std_logic;
        RESET: in std_logic;
        O  : out std_logic_vector (1 downto 0)
   
);
end moore_fsm;

architecture Behavioral of moore_fsm is
    type state_node is (IDLE, F1, F2, F3);
    signal next_state, current_state : state_node;
    
    signal O_reg : std_logic_vector(1 downto 0);
    
begin 
    --STATE <= current_state;   
    state_reg : process(CLK,RESET)
    begin
        if (RESET = '1') then
           current_state <= IDLE;
        elsif (CLK'event and CLK= '1') then
            current_state <= next_state;
        end if;
    end process;
    
    comb_logic : process(current_state,A)
    begin
        case current_state is
            when IDLE =>
                    case A is
                    when "00" => next_state <= IDLE;
                    when "01" => next_state <= F1;
                    when "10" => next_state <= F2;
                    when "11" => next_state <= F3;
                    when others => next_state <= IDLE;
                    end case;
            when F1 => 
                    case A is
                    when "00" => next_state <= IDLE;
                    when "01" => next_state <= F1;
                    when "10" => next_state <= F2;
                    when "11" => next_state <= F3;
                    when others => next_state <= IDLE;
                    end case; 
            when F2 => 
                    case A is
                    when "00" => next_state <= IDLE;
                    when "01" => next_state <= F1;
                    when "10" => next_state <= F2;
                    when "11" => next_state <= F3;
                    when others => next_state <= IDLE;
                    end case;
            when F3 => 
                    case A is
                    when "00" => next_state <= IDLE;
                    when "01" => next_state <= F1;
                    when "10" => next_state <= F2;
                    when "11" => next_state <= F3;
                    when others => next_state <= IDLE;
                    end case;
            when others =>
                        next_state <= IDLE;
        end case;
    end process;
    
    output_reg : process(CLK, RESET)
    begin
        if RESET = '1' then
            O_reg <= "00";
        elsif rising_edge(CLK) then
            case current_state is
                when F3   => O_reg <= "11";
                when others => O_reg <= "00";
            end case;
        end if;
    end process;

    -- Final output
    O <= O_reg;
end Behavioral;
