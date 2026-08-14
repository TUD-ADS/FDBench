--------------------------------------------------------------------------------
-- Testbench for Gaussian Filter - CORRECTED VERSION
-- Tests the 3x3 Gaussian filter with known input patterns
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;



entity gaussian_filter_tb is
end gaussian_filter_tb;

architecture Behavioral of gaussian_filter_tb is

    -- Helper function for minimum
    function minimum(a, b: integer) return integer is
    begin
        if a < b then
            return a;
        else
            return b;
        end if;
    end function;

    -- Component declaration
    component gaussian_filter is
        Generic (
            DATA_WIDTH : integer := 8;
            IMAGE_WIDTH : integer := 640
        );
        Port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            pixel_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            valid_in    : in  std_logic;
            pixel_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            valid_out   : out std_logic
        );
    end component;
    
    -- Testbench parameters (smaller for simulation)
    constant DATA_WIDTH : integer := 8;
    constant IMAGE_WIDTH : integer := 8;  -- Small test image
    constant IMAGE_HEIGHT : integer := 8;
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
    -- Signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal pixel_in    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal valid_in    : std_logic := '0';
    signal pixel_out   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal valid_out   : std_logic;
    
    -- Test control
    signal sim_done : boolean := false;
    
    -- Test image (8x8) - solid white square in center
    type image_type is array (0 to IMAGE_HEIGHT-1, 0 to IMAGE_WIDTH-1) of integer range 0 to 255;
    signal test_image : image_type := (
        (  0,   0,   0,   0,   0,   0,   0,   0),
        (  0,   0,   0,   0,   0,   0,   0,   0),
        (  0,   0, 255, 255, 255, 255,   0,   0),
        (  0,   0, 255, 255, 255, 255,   0,   0),
        (  0,   0, 255, 255, 255, 255,   0,   0),
        (  0,   0, 255, 255, 255, 255,   0,   0),
        (  0,   0,   0,   0,   0,   0,   0,   0),
        (  0,   0,   0,   0,   0,   0,   0,   0)
    );
    
    -- Output image storage
    type output_image_type is array (0 to 100) of integer range 0 to 255;
    signal output_pixels : output_image_type := (others => 0);
    signal output_count : integer := 0;
    
begin

    -- Instantiate the Unit Under Test (UUT)
    uut: gaussian_filter
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            IMAGE_WIDTH => IMAGE_WIDTH
        )
        port map (
            clk         => clk,
            rst         => rst,
            pixel_in    => pixel_in,
            valid_in    => valid_in,
            pixel_out   => pixel_out,
            valid_out   => valid_out
        );

    -- Clock generation
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
        variable row : integer;
        variable col : integer;
        variable pixel_count : integer := 0;
    begin
        -- Initialize
        rst <= '1';
        valid_in <= '0';
        pixel_in <= (others => '0');
        wait for CLK_PERIOD * 5;
        
        rst <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Print test start
        report "========================================";
        report "Starting Gaussian Filter Test";
        report "Image size: " & integer'image(IMAGE_WIDTH) & "x" & integer'image(IMAGE_HEIGHT);
        report "========================================";
        
        wait for CLK_PERIOD;
        
        -- Send test image pixel by pixel
        report "Sending test image (row by row)...";
        for row in 0 to IMAGE_HEIGHT-1 loop
            for col in 0 to IMAGE_WIDTH-1 loop
                pixel_in <= std_logic_vector(to_unsigned(test_image(row, col), DATA_WIDTH));
                valid_in <= '1';
                
                if row < 3 or (row = 3 and col < 3) then
                    report "  Input [" & integer'image(row) & "][" & integer'image(col) & "] = " & 
                           integer'image(test_image(row, col));
                end if;
                
                pixel_count := pixel_count + 1;
                wait for CLK_PERIOD;
            end loop;
        end loop;
        
        report "Total pixels sent: " & integer'image(pixel_count);
        
        valid_in <= '0';
        pixel_in <= (others => '0');
        
        -- Wait for all outputs to be generated
        report "Waiting for outputs to complete...";
        wait for CLK_PERIOD * 50;
        
        -- Print results
        report "========================================";
        report "TEST RESULTS";
        report "========================================";
        report "Total output pixels received: " & integer'image(output_count);
        
        if output_count > 0 then
            report "SUCCESS: Filter produced outputs!";
            report "First few output values:";
            for i in 0 to minimum(9, output_count-1) loop
                report "  Output[" & integer'image(i) & "] = " & integer'image(output_pixels(i));
            end loop;
        else
            report "ERROR: No outputs were generated!";
        end if;
        
        report "========================================";
        report "Test completed";
        report "========================================";
        
        -- End simulation
        wait for CLK_PERIOD * 10;
        sim_done <= true;
             wait for 20 ns;
        report "Simulation completed." severity note;
        std.env.stop;
    end process;

    -- Output capture process
output_proc: process(clk)
    variable L : line;   -- ? moved here
begin
    if rising_edge(clk) then
        if rst = '1' then
            output_count <= 0;

        elsif valid_out = '1' then
            -- Store output pixel
            output_pixels(output_count) <= to_integer(unsigned(pixel_out));

            -- Build report line
            write(L, string'("OUTPUT["));
            write(L, output_count);
            write(L, string'("] = "));
            write(L, to_integer(unsigned(pixel_out)));
            write(L, string'(" (0x"));
            hwrite(L, pixel_out);
            write(L, string'(")"));

            report L.all;

            output_count <= output_count + 1;
        end if;
    end if;
end process;

end Behavioral;