----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 04:54:28 AM
-- Design Name: 
-- Module Name: g_filter_meta_tb - Behavioral
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

entity g_filter_meta_tb is
--  Port ( );
end g_filter_meta_tb;

architecture Behavioral of g_filter_meta_tb is


    constant W : integer := 8;
    constant H : integer := 8;
    constant CLK_PERIOD : time := 10 ns;

    signal clk, rst : std_logic := '0';
    signal pixel_in : std_logic_vector(7 downto 0);
    signal valid_in : std_logic;
    signal pixel_out : std_logic_vector(7 downto 0);
    signal valid_out : std_logic;

    type image_t is array (0 to H-1, 0 to W-1) of integer;

    signal img : image_t := (
        (0,0,0,0,0,0,0,0),
        (0,0,0,0,0,0,0,0),
        (0,0,255,255,255,255,0,0),
        (0,0,255,255,255,255,0,0),
        (0,0,255,255,255,255,0,0),
        (0,0,255,255,255,255,0,0),
        (0,0,0,0,0,0,0,0),
        (0,0,0,0,0,0,0,0)
    );

    signal expected : image_t := (others => (others => 0));

begin

----------------------------------------------------------------
-- DUT
----------------------------------------------------------------
uut: entity work.g_filter_meta
    generic map (
        DATA_WIDTH => 8,
        IMAGE_WIDTH => W
    )
    port map (
        clk => clk,
        rst => rst,
        pixel_in => pixel_in,
        valid_in => valid_in,
        pixel_out => pixel_out,
        valid_out => valid_out
    );

----------------------------------------------------------------
-- CLOCK
----------------------------------------------------------------
    clk_process : process
    begin
       
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
       
    end process;
----------------------------------------------------------------
-- GOLDEN MODEL
----------------------------------------------------------------
process
    variable sum : integer;
begin
    wait for 1 ns;

    for i in 1 to H-2 loop
        for j in 1 to W-2 loop
            sum :=
                img(i-1,j-1) + 2*img(i-1,j) + img(i-1,j+1) +
                2*img(i,j-1) + 4*img(i,j) + 2*img(i,j+1) +
                img(i+1,j-1) + 2*img(i+1,j) + img(i+1,j+1);

            expected(i,j) <= sum / 16;
        end loop;
    end loop;

    wait;
end process;

----------------------------------------------------------------
-- STIMULUS
----------------------------------------------------------------
process
begin
    rst <= '1';
    wait for 30 ns;
    rst <= '0';

    for i in 0 to H-1 loop
        for j in 0 to W-1 loop
            pixel_in <= std_logic_vector(to_unsigned(img(i,j),8));
            valid_in <= '1';
            wait for CLK_PERIOD;
        end loop;
    end loop;

    valid_in <= '0';
     wait for 20 ns;
        report "Simulation completed." severity note;
        std.env.stop;
end process;

----------------------------------------------------------------
-- VERIFY (PIPELINE FIXED)
----------------------------------------------------------------
process(clk)
    variable row,col : integer := 0;

    type arr is array(0 to 3) of integer;
    variable rp,cp : arr := (others => 0);

    variable act,exp : integer;

begin
    if rising_edge(clk) then

        -- pipeline shift
        rp(0):=row; cp(0):=col;
        for i in 1 to 3 loop
            rp(i):=rp(i-1);
            cp(i):=cp(i-1);
        end loop;

        if valid_out='1' then

            act := to_integer(unsigned(pixel_out));

            if rp(3)>=2 and cp(3)>=2 then
                exp := expected(rp(3),cp(3));

                assert act = exp
                report "Error : METASTABILITY (" &
                       integer'image(rp(3)) & "," &
                       integer'image(cp(3)) &
                       ") Exp=" & integer'image(exp) &
                       " Got=" & integer'image(act)
                severity error;
            end if;

            if col = W-1 then
                col := 0;
                row := row + 1;
            else
                col := col + 1;
            end if;

        end if;
    end if;
end process;


end Behavioral;
