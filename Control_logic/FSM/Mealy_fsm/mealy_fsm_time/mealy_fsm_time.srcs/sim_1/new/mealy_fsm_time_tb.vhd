----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/15/2026 03:30:04 PM
-- Design Name: 
-- Module Name: mealy_fsm_time_tb - Behavioral
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

entity mealy_fsm_time_tb is
--  Port ( );
end mealy_fsm_time_tb;

architecture Behavioral of mealy_fsm_time_tb is

signal CLK   : std_logic := '0';
signal RESET : std_logic := '1';
signal A     : std_logic_vector(1 downto 0);

signal O_bug : std_logic_vector(1 downto 0);

signal inserted_bug_count : integer := 0;
signal detected_bug_count : integer := 0;
constant clk_period  : time := 10 ns;


signal cycle : integer := 0;

begin

    dut : entity work.mealy_fsm_time 

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

stim_proc : process(CLK)
begin
    if rising_edge(CLK) then

        cycle <= cycle + 1;

        if cycle = 3 then
            RESET <= '0';
        end if;
        
         if cycle = 60 then
            RESET <= '1';
         elsif cycle = 62 then
            RESET <= '0';
        end if;

        case cycle mod 4 is
            when 0 => A <= "00";
            when 1 => A <= "10";
            when 2 => A <= "11";
            when others => A <= "01";
        end case;
        end if;
end process;


-- MONITOR

monitor : process(CLK)
begin
    if rising_edge(CLK) then

        for i in 0 to 3 loop

            if O_bug /= "00" and O_bug /= "11" then
                inserted_bug_count <= inserted_bug_count + 1;
            end if;

            if A="11" and O_bug/="11" then
                detected_bug_count <= detected_bug_count + 1;
            end if;

        end loop;

    end if;
end process;



end Behavioral;
