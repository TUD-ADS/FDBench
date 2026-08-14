----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/27/2026 08:36:11 PM
-- Design Name: 
-- Module Name: g_filter - Behavioral
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

--------------------------------------------------------------------------------
-- Gaussian Filter (3x3 Kernel)
-- Fixed-point implementation using integer arithmetic
-- Gaussian kernel approximation:
--   1  2  1
--   2  4  2  * 1/16
--   1  2  1
--------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity g_filter_cgat is
    Generic (
        DATA_WIDTH : integer := 8;          -- Input pixel width
        IMAGE_WIDTH : integer := 640        -- Image width for line buffering
    );
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        
        -- Input pixel stream
        pixel_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_in    : in  std_logic;
        
        -- Output filtered pixel
        pixel_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_out   : out std_logic
    );
end g_filter_cgat;

architecture behavioral of g_filter_cgat is
    
    -- Line buffer type for storing two rows
    type line_buffer_type is array (0 to IMAGE_WIDTH-1) of unsigned(DATA_WIDTH-1 downto 0);
    
    -- Line buffers for implementing 3x3 window
    signal line_buffer_0 : line_buffer_type := (others => (others => '0'));
    signal line_buffer_1 : line_buffer_type := (others => (others => '0'));
    
    -- Column and row counters
    signal col_count : integer range 0 to IMAGE_WIDTH-1 := 0;
    signal row_count : integer range 0 to 1023 := 0;  -- Increased range
    
    -- 3x3 window registers
    signal win_00, win_01, win_02 : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    signal win_10, win_11, win_12 : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    signal win_20, win_21, win_22 : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    
    -- Gaussian kernel coefficients (sum = 16)
    constant COEF_CORNER : integer := 1;
    constant COEF_EDGE   : integer := 2;
    constant COEF_CENTER : integer := 4;
    
    -- Pipeline valid signals
    signal valid_stage1 : std_logic := '0';
    signal valid_stage2 : std_logic := '0';
    signal valid_stage3 : std_logic := '0';
    
    -- Multiplication results (extended width to prevent overflow)
    signal mult_00, mult_01, mult_02 : unsigned(DATA_WIDTH+3 downto 0) := (others => '0');
    signal mult_10, mult_11, mult_12 : unsigned(DATA_WIDTH+3 downto 0) := (others => '0');
    signal mult_20, mult_21, mult_22 : unsigned(DATA_WIDTH+3 downto 0) := (others => '0');
    
    -- Accumulation result
    signal acc_result : unsigned(DATA_WIDTH+7 downto 0) := (others => '0');
    signal final_result : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    
begin

    -- Main process for line buffering and window sliding
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset all signals
                col_count <= 0;
                row_count <= 0;
                valid_stage1 <= '0';
                valid_stage2 <= '0';
                valid_stage3 <= '0';
                
                win_00 <= (others => '0');
                win_01 <= (others => '0');
                win_02 <= (others => '0');
                win_10 <= (others => '0');
                win_11 <= (others => '0');
                win_12 <= (others => '0');
                win_20 <= (others => '0');
                win_21 <= (others => '0');
                win_22 <= (others => '0');
                
                mult_00 <= (others => '0');
                mult_01 <= (others => '0');
                mult_02 <= (others => '0');
                mult_10 <= (others => '0');
                mult_11 <= (others => '0');
                mult_12 <= (others => '0');
                mult_20 <= (others => '0');
                mult_21 <= (others => '0');
                mult_22 <= (others => '0');
                
                acc_result <= (others => '0');
                final_result <= (others => '0');
                
            else
                -- Default: propagate zeros through pipeline when no valid input
                valid_stage1 <= '0';
                
                if valid_in = '1' then
                    -- Shift line buffers and update window
                    -- Current pixel goes to top row
                    win_00 <= win_01;
                    win_01 <= win_02;
                    win_02 <= unsigned(pixel_in);
                    
                    -- Line buffer 1 goes to middle row
                    win_10 <= win_11;
                    win_11 <= win_12;
                    win_12 <= line_buffer_0(col_count);
                    
                    -- Line buffer 0 goes to bottom row
                    win_20 <= win_21;
                    win_21 <= win_22;
                    win_22 <= line_buffer_1(col_count);
                    
                    -- Update line buffers
                    line_buffer_0(col_count) <= unsigned(pixel_in);
                    line_buffer_1(col_count) <= line_buffer_0(col_count);
                    
                    -- Update column counter
                    if col_count = IMAGE_WIDTH-1 then
                        col_count <= 0;
                        row_count <= row_count + 1;
                    else
                        col_count <= col_count + 1;
                    end if;
                    
                    -- Valid output after we have filled at least 2 rows and moved past first 2 columns
                    if row_count >= 2 and col_count >= 2 then
                        valid_stage1 <= '1';
                    end if;
                end if;
                
                -- Pipeline stage 1: Multiply with kernel coefficients
                if valid_stage1 = '1' then
                    mult_00 <= resize(win_00 * COEF_CORNER, DATA_WIDTH+4);
                    mult_01 <= resize(win_01 * COEF_EDGE,   DATA_WIDTH+4);
                    mult_02 <= resize(win_02 * COEF_CORNER, DATA_WIDTH+4);
                    
                    mult_10 <= resize(win_10 * COEF_EDGE,   DATA_WIDTH+4);
                    mult_11 <= resize(win_11 * COEF_CENTER, DATA_WIDTH+4);
                    mult_12 <= resize(win_12 * COEF_EDGE,   DATA_WIDTH+4);
                    
                    mult_20 <= resize(win_20 * COEF_CORNER, DATA_WIDTH+4);
                    mult_21 <= resize(win_21 * COEF_EDGE,   DATA_WIDTH+4);
                    mult_22 <= resize(win_22 * COEF_CORNER, DATA_WIDTH+4);
                end if;
                valid_stage2 <= valid_stage1;
                
                -- Pipeline stage 2: Accumulate and divide by 16 (right shift by 4)
                if valid_stage2 = '1' then
                    acc_result <= resize(mult_00, DATA_WIDTH+8) + 
                                  resize(mult_01, DATA_WIDTH+8) + 
                                  resize(mult_02, DATA_WIDTH+8) +
                                  resize(mult_10, DATA_WIDTH+8) + 
                                  resize(mult_11, DATA_WIDTH+8) + 
                                  resize(mult_12, DATA_WIDTH+8) +
                                  resize(mult_20, DATA_WIDTH+8) + 
                                  resize(mult_21, DATA_WIDTH+8) + 
                                  resize(mult_22, DATA_WIDTH+8);
                end if;
                valid_stage3 <= valid_stage2;
                
                -- Pipeline stage 3: Normalize (divide by 16) and output
                if valid_stage3 = '1' then
                    final_result <= acc_result(DATA_WIDTH+3 downto 4);  -- Right shift by 4 = divide by 16
                end if;
                
            end if;
        end if;
    end process;
    
    -- Output assignment
    pixel_out <= std_logic_vector(final_result);
    valid_out <= valid_stage3;
    
end behavioral;

