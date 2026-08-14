library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity moore_fsm_time is
Port (  A: in std_logic_vector (1 downto 0);
        CLK: in std_logic;
        RESET: in std_logic;
        O  : out std_logic_vector (1 downto 0)
);
end moore_fsm_time;

architecture Behavioral of moore_fsm_time is

    type state_node is (IDLE, F1, F2, F3);
    signal next_state, current_state : state_node := IDLE;

    signal timing_enable : std_logic;

    -- Long path signals
    signal long_path : std_logic;

begin

------------------------------------------------------------------
-- ENABLE LOGIC
------------------------------------------------------------------
timing_enable <= A(0) xor A(1);

------------------------------------------------------------------
-- STATE REGISTER
------------------------------------------------------------------
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

------------------------------------------------------------------
-- ? LONG COMBINATIONAL PATH (CRITICAL PATH)
------------------------------------------------------------------
long_comb : process(A)
    variable v1, v2, v3, v4, v5 : unsigned(15 downto 0);
    variable mult_tmp : unsigned(31 downto 0);
begin
    v1 := unsigned("00000000000000" & A);

    v2 := v1 + to_unsigned(123, 16);
    v3 := v2 xor to_unsigned(456, 16);
    v4 := shift_left(v3, 2) + v2;

    mult_tmp := v4 * 3;
    v5 := resize(mult_tmp, 16) + v3;

    -- FINAL LONG PATH OUTPUT
    if v5(3 downto 0) = "1010" then
        long_path <= '1';
    else
        long_path <= '0';
    end if;
end process;

------------------------------------------------------------------
-- ? NEXT STATE LOGIC (NOW DEPENDS ON LONG PATH)
------------------------------------------------------------------
comb_logic : process(current_state, A, long_path)
begin
    case current_state is

        when IDLE =>
            if long_path = '1' then
                next_state <= F3;  -- force long path usage
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
            if long_path = '1' then
                next_state <= IDLE;
            else
                next_state <= F2;
            end if;

        when F2 =>
            if long_path = '1' then
                next_state <= F1;
            else
                next_state <= F3;
            end if;

        when F3 =>
            if long_path = '1' then
                next_state <= F2;
            else
                next_state <= IDLE;
            end if;

        when others =>
            next_state <= IDLE;

    end case;
end process;

------------------------------------------------------------------
-- MOORE OUTPUT LOGIC (STATE ONLY)
------------------------------------------------------------------
output_logic : process(current_state)
begin
    case current_state is
        when F3     => O <= "11";
        when others => O <= "00";
    end case;
end process;

end Behavioral;