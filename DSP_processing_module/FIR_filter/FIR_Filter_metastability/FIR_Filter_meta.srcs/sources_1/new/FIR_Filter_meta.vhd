----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 03:40:34 AM
-- Design Name: 
-- Module Name: FIR_Filter_meta - Behavioral
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

entity FIR_Filter_meta is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        data_in  : in  std_logic_vector(15 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );end FIR_Filter_meta;

architecture Behavioral of FIR_Filter_meta is


     -- FIR parameters
    type coeff_array_t is array (0 to 31) of signed(10 downto 0);
    type delay_array_t is array (0 to 31) of signed(15 downto 0);

    -- coefficients
    constant coeffs : coeff_array_t := (
        to_signed(-17,11),  to_signed(-20,11),  to_signed(-26,11),  to_signed(-31,11),
        to_signed(-29,11),  to_signed(-15,11),  to_signed(20,11),   to_signed(82,11),
        to_signed(174,11),  to_signed(294,11),  to_signed(437,11),  to_signed(591,11),
        to_signed(741,11),  to_signed(873,11),  to_signed(971,11),  to_signed(1023,11),
        to_signed(1023,11), to_signed(971,11),  to_signed(873,11),  to_signed(741,11),
        to_signed(591,11),  to_signed(437,11),  to_signed(294,11),  to_signed(174,11),
        to_signed(82,11),   to_signed(20,11),   to_signed(-15,11),  to_signed(-29,11),
        to_signed(-31,11),  to_signed(-26,11),  to_signed(-20,11),  to_signed(-17,11)
    );

    signal delay_line : delay_array_t := (others => (others => '0'));
    signal final_sum  : signed(31 downto 0) := (others => '0');
    signal meta_sig   : std_logic := '0';begin

    process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            meta_sig <= '0';
        else
            meta_sig <= not meta_sig;  -- pseudo async behavior
        end if;
    end if;
end process;
--------------------------------------------------------
-- DELAY LINE
--------------------------------------------------------
process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            delay_line <= (others => (others => '0'));
        else
            for i in 31 downto 1 loop

                -- BUG: conditional shift corruption
                if meta_sig = '1' then
                    delay_line(i) <= delay_line(i-1);
          
                end if;

            end loop;

            delay_line(0) <= signed(data_in);
        end if;
    end if;
end process;

process(clk)
    variable acc : signed(31 downto 0);
begin
    if rising_edge(clk) then
        if reset = '1' then
            final_sum <= (others => '0');
        else
            acc := (others => '0');

            for i in 0 to 31 loop
                if meta_sig = '1' then
                    acc := acc + resize(delay_line(i) * coeffs(i), 32);
          
                end if;
            end loop;

            final_sum <= acc;
        end if;
    end if;
end process;

--------------------------------------------------------
-- OUTPUT
--------------------------------------------------------
data_out <= std_logic_vector(final_sum);

end Behavioral;
