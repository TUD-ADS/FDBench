----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2026 10:44:08 AM
-- Design Name: 
-- Module Name: fsm_counter - Behavioral
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

entity fsm_counter is
    generic (
        N : natural := 4
    );
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        ready   : in  std_logic;

        -- Outputs from FSM
        ack     : out std_logic;
        busy    : out std_logic;
        done    : out std_logic;

        -- Debug / observation
        counter_out : out unsigned(N-1 downto 0);
        data_out    : out std_logic_vector(7 downto 0)
    );end fsm_counter;

architecture Behavioral of fsm_counter is

  -- Internal signals
    signal cnt        : unsigned(N-1 downto 0);
    signal req        : std_logic;
    signal data_in    : std_logic_vector(7 downto 0);

begin

    ------------------------------------------------------------------
    -- Instantiate ASYNC COUNTER
    ------------------------------------------------------------------
    U_COUNTER : entity work.as_counter
        generic map (
            n => N
        )
        port map (
            clock   => clk,
            reset   => rst,
            counter => cnt
        );
    ------------------------------------------------------------------
    -- Instantiate FSM
    ------------------------------------------------------------------
    U_FSM : entity work.fsm
        port map (
            clk      => clk,
            rst      => rst,
            req      => req,
            data_in  => data_in,
            ready    => ready,
            ack      => ack,
            busy     => busy,
            done     => done,
            data_out => data_out
        );
        
            ------------------------------------------------------------------
    -- Cross-module logic (IMPORTANT PART)
    ------------------------------------------------------------------

       -- Convert counter to 8-bit data
    data_in <= std_logic_vector(resize(cnt, 8));

    -- Generate request when counter hits midpoint
    process(cnt)
    begin
        if cnt = (2**N)/2 then
            req <= '1';
        else
            req <= '0';
        end if;
    end process;
    

    ------------------------------------------------------------------
    -- Debug outputs
    ------------------------------------------------------------------
    counter_out <= cnt;



end Behavioral;
