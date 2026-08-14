----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/15/2026 04:59:44 PM
-- Design Name: 
-- Module Name: moore_fsm_meta_tb - Behavioral
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

entity moore_fsm_meta_tb is
--  Port ( );
end moore_fsm_meta_tb;

architecture Behavioral of moore_fsm_meta_tb is


signal CLK   : std_logic := '0';
signal RESET : std_logic := '1';
signal A     : std_logic_vector(1 downto 0);

signal O_bug : std_logic_vector(1 downto 0);

signal inserted_bug_count : integer := 0;
signal detected_bug_count : integer := 0;
constant clk_period  : time := 10 ns;


signal cycle : integer := 0;

begin

    dut : entity work.moore_fsm_meta 

    port map ( A => A,
               O => O_bug,
               CLK => CLK,
               RESET => RESET
               );

-- CLOCK

clk_inst : process
begin
    --while true loop
        CLK <= '0';
        wait for clk_period/2;
        CLK <= '1';
        wait for clk_period/2;
   --end loop;
end process;
-- STIMULUS
stim_proc : process
begin

     -- INITIAL RESET
    RESET <= '1';
    A <= "00";

    wait for 3*clk_period;
    RESET <= '0';

    -- MAIN STIMULUS LOOP
    for i in 0 to 100 loop

        -- Apply input before clock edge
        case i mod 4 is
            when 0 => A <= "00";
            when 1 => A <= "10";
            when 2 => A <= "11";
            when others => A <= "01";
        end case;

    wait until rising_edge(clk);

 -- RESET INJECTION
        if i = 60 then
            RESET <= '1';
        elsif i = 63 then
            RESET <= '0';
        end if;

    end loop;

  -- END SIMULATION
    wait for 20 ns;
    report "Simulation Finished";
    std.env.stop;

end process;

------------------------------------------------
-- MONITOR
------------------------------------------------
monitor : process(CLK)
begin
    if rising_edge(CLK) then

        ------------------------------------------------
        -- VALID OUTPUT CHECK
        ------------------------------------------------
        assert (O_bug = "00" or O_bug = "11")
        report "ERROR: Invalid output detected METASTABILITY"
        severity error;

        if not (O_bug = "00" or O_bug = "11") then
            detected_bug_count <= detected_bug_count + 1;
        end if;

        ------------------------------------------------
        -- FUNCTIONAL CHECK (A = 11 ? O = 11)
        ------------------------------------------------
        assert (A = "01" and O_bug = "11" and RESET <= '0')
        report "ERROR: Wrong output because of METASTABILITY"
        severity error;

        if (A = "01" and O_bug /= "11") then
            detected_bug_count <= detected_bug_count + 1;
        end if;

        ------------------------------------------------
        -- RESET CHECK
        ------------------------------------------------
        if RESET = '1' then
            assert O_bug = "00"
            report "ERROR: Output not reset properly METASTABILITY"
            severity error;

            if O_bug /= "00" then
                detected_bug_count <= detected_bug_count + 1;
            end if;
        end if;

    end if;
end process;
end Behavioral;
