----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/17/2026 04:36:31 PM
-- Design Name: 
-- Module Name: fsm_uart_meta - Behavioral
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

entity fsm_uart_meta is
Port ( 
        baud_clk : in  std_logic;
        reset    : in  std_logic;

        -- Transmitter
        tx_start : in  std_logic;
        tx_data  : in  std_logic_vector(7 downto 0);
        tx_busy  : out std_logic;
        tx       : out std_logic;

        -- Receiver
        rx       : in  std_logic;
        rx_data  : out std_logic_vector(7 downto 0);
        rx_done  : out std_logic
            );end fsm_uart_meta;

architecture Behavioral of fsm_uart_meta is

      -- TX FSM
    type tx_state_t is (TX_IDLE, TX_START_ST, TX_DATA_ST, TX_STOP);
    signal tx_state : tx_state_t := TX_IDLE;

    signal tx_shift : std_logic_vector(7 downto 0);
    signal tx_bit   : integer range 0 to 7 := 0;

    -- RX FSM
    type rx_state_t is (RX_IDLE, RX_START, RX_DATA_ST, RX_STOP);
    signal rx_state : rx_state_t := RX_IDLE;

    signal rx_shift : std_logic_vector(7 downto 0);
    signal rx_bit   : integer range 0 to 7 := 0;

begin

       Transmission : process(baud_clk)
    begin
        if rising_edge(baud_clk) then
       
                case tx_state is

                    when TX_IDLE =>
                        tx <= '1';
                        tx_busy <= '0';

                        if tx_start = '1' then
                            tx_shift <= tx_data;
                            tx_state <= TX_START_ST;
                            tx_busy <= '1';
                        end if;

                    when TX_START_ST =>
                        tx <= '0';            -- start bit
                        tx_bit <= 0;
                        tx_state <= TX_DATA_ST;

                    when TX_DATA_ST =>
                        tx <= tx_shift(tx_bit);

                        if tx_bit = 7 then
                            tx_state <= TX_STOP;
                        else
                            tx_bit <= tx_bit + 1;
                        end if;

                    when TX_STOP =>
                        tx <= '1';            -- stop bit
                        tx_state <= TX_IDLE;

                end case;
            elsif reset = '1' then
                tx_state <= TX_IDLE;
                tx <= '1';
                tx_busy <= '0';
                tx_bit <= 0;
        end if;
    end process;


Receiver :     process(baud_clk)
    begin
        if rising_edge(baud_clk) then

                rx_done <= '0';

                case rx_state is

                    when RX_IDLE =>
                        if rx = '0' then          -- start bit detected
                            rx_state <= RX_START;
                        end if;

                    when RX_START =>
                        rx_bit <= 0;
                        rx_state <= RX_DATA_ST;

                    when RX_DATA_ST =>
                        rx_shift(rx_bit) <= rx;

                        if rx_bit = 7 then
                            rx_state <= RX_STOP;
                        else
                            rx_bit <= rx_bit + 1;
                        end if;

                    when RX_STOP =>
                        if rx = '1' then          -- valid stop bit
                            rx_data <= rx_shift;
                            rx_done <= '1';
                        end if;
                        rx_state <= RX_IDLE;

                end case;
           elsif reset = '1' then
                rx_state <= RX_IDLE;
                rx_bit <= 0;
                rx_done <= '0';

        end if;
    end process;
end Behavioral;
