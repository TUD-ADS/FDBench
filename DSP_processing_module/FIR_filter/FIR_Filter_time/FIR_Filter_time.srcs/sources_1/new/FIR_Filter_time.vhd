----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 03:41:11 AM
-- Design Name: 
-- Module Name: FIR_Filter_time - Behavioral
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

entity FIR_Filter_time is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        data_in  : in  std_logic_vector(15 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );end FIR_Filter_time;

architecture Behavioral of FIR_Filter_time is


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
    signal sum  : signed(31 downto 0) := (others => '0');
    --signal sum        : signed(31 downto 0);
begin

--------------------------------------------------------
-- DELAY LINE
--------------------------------------------------------
process(clk)
    variable acc : signed(31 downto 0);
begin
    if rising_edge(clk) then

        for i in 31 downto 1 loop
            delay_line(i) <= delay_line(i-1);
        end loop;

        delay_line(0) <= signed(data_in);

        acc := (others => '0');

        -- long combinational chain
        for i in 0 to 31 loop
            acc := acc + resize(delay_line(i) * to_signed(i,11), 32);
        end loop;

        sum <= acc;

    end if;
end process;

--------------------------------------------------------
-- OUTPUT
--------------------------------------------------------
data_out <= std_logic_vector(sum);


end Behavioral;
