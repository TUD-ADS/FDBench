library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mealy_fsm_time is
Port (  A: in std_logic_vector (1 downto 0);
        CLK: in std_logic;
        RESET: in std_logic;
        O  : out std_logic_vector (1 downto 0)
);
end mealy_fsm_time;

architecture Behavioral of mealy_fsm_time is

    type state_node is (IDLE, F1, F2, F3);
    signal next_state, current_state : state_node := IDLE;

    signal timing_enable : std_logic;

    -- ? Long combinational chain signals
    signal comb1, comb2, comb3, comb4, comb5 : unsigned(15 downto 0);
    signal long_path : std_logic;

begin


-- ENABLE LOGIC

timing_enable <= A(0) xor A(1);


-- STATE REGISTER

state_reg : process(CLK, RESET)
begin
    if (RESET = '1') then
        current_state <= IDLE;
    elsif rising_edge(CLK) then
        if timing_enable = '0' then
            current_state <= next_state;
        end if;
    end if;
end process;


-- ? LONG COMBINATIONAL PATH (FIXED)
long_comb : process(A)
    variable v1, v2, v3, v4, v5 : unsigned(15 downto 0);
    variable mult_tmp : unsigned(31 downto 0); -- for multiplication
begin
    -- Expand input (14 zeros + 2-bit A = 16 bits)
    v1 := unsigned("00000000000000" & A);

    v2 := v1 + to_unsigned(123, 16);
    v3 := v2 xor to_unsigned(456, 16);
    v4 := shift_left(v3, 2) + v2;

    -- ? FIX: handle multiplication width
    mult_tmp := v4 * 3;
    v5 := resize(mult_tmp, 16) + v3;

    -- Assign signals
    comb1 <= v1;
    comb2 <= v2;
    comb3 <= v3;
    comb4 <= v4;
    comb5 <= v5;

    -- Final condition
    if v5(3 downto 0) = "1010" then
        long_path <= '1';
    else
        long_path <= '0';
    end if;
end process;
-- FSM COMBINATIONAL LOGIC
comb_logic : process(current_state, A, long_path)
begin
    case current_state is

        when IDLE =>
            O <= "00";
            if long_path = '1' then
                next_state <= F3;
            else
                case A is
                    when "00" => next_state <= IDLE;
                    when "01" => next_state <= F1;
                    when "10" => next_state <= F2;
                    when "11" => next_state <= F3;
                    when others => next_state <= IDLE;
                end case;
            end if;

        when F1 =>
            O <= "00";
            if long_path = '1' then
                next_state <= IDLE;
            else
                next_state <= F2;
            end if;

        when F2 =>
            O <= "00";
            if long_path = '1' then
                next_state <= F1;
            else
                next_state <= F3;
            end if;

        when F3 =>
            O <= "11";
            if long_path = '1' then
                next_state <= F2;
            else
                next_state <= IDLE;
            end if;

        when others =>
            O <= "00";
            next_state <= IDLE;

    end case;
end process;

end Behavioral;