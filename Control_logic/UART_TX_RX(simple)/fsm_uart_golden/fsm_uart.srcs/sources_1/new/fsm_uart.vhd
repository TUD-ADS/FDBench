library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_uart is
Port ( 
    baud_clk : in  std_logic;
    reset    : in  std_logic;

    tx_start : in  std_logic;
    tx_data  : in  std_logic_vector(7 downto 0);
    tx_busy  : out std_logic;
    tx       : out std_logic;

    rx       : in  std_logic;
    rx_data  : out std_logic_vector(7 downto 0);
    rx_done  : out std_logic
);
end fsm_uart;

architecture Behavioral of fsm_uart is

constant BAUD_DIV : integer := 16;

signal baud_cnt  : integer range 0 to BAUD_DIV-1 := 0;
signal baud_tick : std_logic := '0';

-- TX
type tx_state_t is (TX_IDLE, TX_START_BIT, TX_DATA_BITS, TX_STOP_BIT);
signal tx_state : tx_state_t := TX_IDLE;

signal tx_shift : std_logic_vector(7 downto 0);
signal tx_bit   : unsigned(2 downto 0) := (others => '0');
signal tx_start_sync : std_logic := '0';

-- RX
type rx_state_t is (RX_IDLE, RX_START_BIT, RX_DATA_BITS, RX_STOP_BIT);
signal rx_state : rx_state_t := RX_IDLE;

signal rx_shift : std_logic_vector(7 downto 0);
signal rx_bit   : unsigned(2 downto 0) := (others => '0');
signal rx_cnt   : integer range 0 to BAUD_DIV := 0;

begin

----------------------------------------------------------------
-- BAUD GENERATOR
----------------------------------------------------------------
process(baud_clk)
begin
    if rising_edge(baud_clk) then
        if reset = '1' then
            baud_cnt  <= 0;
            baud_tick <= '0';
        else
            if baud_cnt = BAUD_DIV-1 then
                baud_cnt  <= 0;
                baud_tick <= '1';
            else
                baud_cnt  <= baud_cnt + 1;
                baud_tick <= '0';
            end if;
        end if;
    end if;
end process;

----------------------------------------------------------------
-- LATCH tx_start (IMPORTANT)
----------------------------------------------------------------
process(baud_clk)
begin
    if rising_edge(baud_clk) then
        if reset = '1' then
            tx_start_sync <= '0';
        elsif tx_start = '1' then
            tx_start_sync <= '1';
        elsif tx_state /= TX_IDLE then
            tx_start_sync <= '0';
        end if;
    end if;
end process;

----------------------------------------------------------------
-- TX FSM
----------------------------------------------------------------
process(baud_clk)
begin
    if rising_edge(baud_clk) then
        if reset = '1' then
            tx_state <= TX_IDLE;
            tx <= '1';
            tx_busy <= '0';
            tx_bit <= (others => '0');

        elsif baud_tick = '1' then

            case tx_state is

                when TX_IDLE =>
                    tx <= '1';
                    tx_busy <= '0';
                    tx_bit <= (others => '0');

                    if tx_start_sync = '1' then
                        tx_shift <= tx_data;
                        tx_state <= TX_START_BIT;
                        tx_busy <= '1';
                    end if;

                when TX_START_BIT =>
                    tx <= '0';
                    tx_busy <= '1';
                    tx_state <= TX_DATA_BITS;

                when TX_DATA_BITS =>
                    tx <= tx_shift(to_integer(tx_bit));
                    tx_busy <= '1';

                    if tx_bit = 7 then
                        tx_state <= TX_STOP_BIT;
                    else
                        tx_bit <= tx_bit + 1;
                    end if;

                when TX_STOP_BIT =>
                    tx <= '1';
                    tx_busy <= '0';  -- FIX
                    tx_state <= TX_IDLE;

            end case;
        end if;
    end if;
end process;

----------------------------------------------------------------
-- RX FSM
----------------------------------------------------------------
process(baud_clk)
begin
    if rising_edge(baud_clk) then
        if reset = '1' then
            rx_state <= RX_IDLE;
            rx_bit   <= (others => '0');
            rx_done  <= '0';
            rx_cnt   <= 0;

        else
            rx_done <= '0';

            case rx_state is

                when RX_IDLE =>
                    rx_cnt <= 0;
                    if rx = '0' then
                        rx_state <= RX_START_BIT;
                    end if;

                when RX_START_BIT =>
                    if rx_cnt = BAUD_DIV/2 then
                        rx_cnt <= 0;
                        rx_bit <= (others => '0');
                        rx_state <= RX_DATA_BITS;
                    else
                        rx_cnt <= rx_cnt + 1;
                    end if;

                when RX_DATA_BITS =>
                    if baud_tick = '1' then
                        rx_shift(to_integer(rx_bit)) <= rx;

                        if rx_bit = 7 then
                            rx_state <= RX_STOP_BIT;
                        else
                            rx_bit <= rx_bit + 1;
                        end if;
                    end if;

                when RX_STOP_BIT =>
                    if baud_tick = '1' then
                        if rx = '1' then
                            rx_data <= rx_shift;
                            rx_done <= '1';
                        end if;
                        rx_state <= RX_IDLE;
                    end if;

            end case;
        end if;
    end if;
end process;

end Behavioral;