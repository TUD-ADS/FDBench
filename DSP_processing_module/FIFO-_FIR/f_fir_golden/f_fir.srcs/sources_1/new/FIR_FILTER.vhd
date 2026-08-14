----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/07/2026 02:30:17 AM
-- Design Name: 
-- Module Name: FIR - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



use IEEE.NUMERIC_STD.ALL;

entity FIR_Filter is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        data_in  : in  std_logic_vector(15 downto 0):= (others => '0');
        --data_in  : in  std_logic_vector(15 downto 0):= (others => '0');
        data_out : out std_logic_vector(31 downto 0)
    );
end FIR_Filter;

architecture Behavioral of FIR_Filter is

    -- ================= TYPES =================
    type coeff_array_t   is array (0 to 31) of signed(10 downto 0);
    type delay_array_t   is array (0 to 31) of signed(15 downto 0);
    type product_array_t is array (0 to 31) of signed(26 downto 0);
    type sum16_array_t   is array (0 to 15) of signed(27 downto 0);
    type sum8_array_t    is array (0 to 7)  of signed(28 downto 0);
    type sum4_array_t    is array (0 to 3)  of signed(29 downto 0);
    type sum2_array_t    is array (0 to 1)  of signed(30 downto 0);

    -- ============== COEFFICIENTS ==============
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

    -- ============== SIGNALS ===================
    signal delay_line : delay_array_t   := (others => (others => '0'));
    signal products   : product_array_t := (others => (others => '0'));
    signal s1         : sum16_array_t   := (others => (others => '0'));
    signal s2         : sum8_array_t    := (others => (others => '0'));
    signal s3         : sum4_array_t    := (others => (others => '0'));
    signal s4         : sum2_array_t    := (others => (others => '0'));
    signal final_sum  : signed(31 downto 0) := (others => '0');

begin

    -- ================= DELAY LINE =================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                delay_line <= (others => (others => '0'));
            else
                for i in 31 downto 1 loop
                    delay_line(i) <= delay_line(i-1);
                end loop;
                delay_line(0) <= signed(data_in);
            end if;
        end if;
    end process;

    -- ================= MULTIPLY =================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                products <= (others => (others => '0'));
       
            else
                for i in 0 to 31 loop
                    products(i) <= delay_line(i) * coeffs(i);
                end loop;
            end if;
        end if;
    end process;

    -- ================= ADDER TREE =================
    process(clk)
    begin
        if rising_edge(clk) then
            for i in 0 to 15 loop
                s1(i) <= resize(products(2*i) + products(2*i+1), 28);
            end loop;
            for i in 0 to 7 loop
                s2(i) <= resize(s1(2*i) + s1(2*i+1), 29);
            end loop;
            for i in 0 to 3 loop
                s3(i) <= resize(s2(2*i) + s2(2*i+1), 30);
            end loop;
            for i in 0 to 1 loop
                s4(i) <= resize(s3(2*i) + s3(2*i+1), 31);
            end loop;
            final_sum <= resize(s4(0) + s4(1), 32);
        end if;
    end process;

    -- ================= OUTPUT =================
    data_out <= std_logic_vector(final_sum);

end Behavioral;
