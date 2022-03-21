----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.03.2019 17:53:39
-- Design Name: 
-- Module Name: AER_IN_tb - Behavioral
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

entity AER_IN_tb is
--  Port ( );
end AER_IN_tb;

architecture Behavioral of AER_IN_tb is

    component AER_IN is
        Port ( 
            i_clk : in  STD_LOGIC;
            i_rst : in  STD_LOGIC;
            --AER handshake
            i_aer_in : in  STD_LOGIC_VECTOR (15 downto 0);
            i_req_in : in  STD_LOGIC;
            o_ack_in : out  STD_LOGIC;
            --AER data output to be processed
            o_aer_data : out STD_LOGIC_VECTOR(15 downto 0);
            o_new_aer_data : out std_logic
        );
    end component;
    
    -- Input signals
    signal i_clk : std_logic := '0';
    signal i_rst : std_logic := '0';
    signal i_aer_in : std_logic_vector(15 downto 0) := (others => '0');
    signal i_req_in : std_logic := '1';
    signal o_ack_in : std_logic;
    
    -- Output signals
    signal o_aer_data : std_logic_vector(15 downto 0);
    signal o_new_aer_data : std_logic;
    
   -- Clock period definitions
    constant i_clk_period : time := 20 ns;

    begin
    
        -- Instantiate the Unit Under Test (UUT)
        uut: AER_IN 
        PORT MAP (
            i_clk => i_clk,
            i_rst => i_rst,
            --AER handshake
            i_aer_in => i_aer_in,
            i_req_in => i_req_in,
            o_ack_in => o_ack_in,
            --AER data output to be processed
            o_aer_data => o_aer_data,
            o_new_aer_data => o_new_aer_data
        );
    
       -- Clock process definitions
       i_clk_process :process
       begin
            i_clk <= '0';
            wait for i_clk_period/2;
            i_clk <= '1';
            wait for i_clk_period/2;
        end process;
     
    
        -- Stimulus process
        stim_proc: process
        begin        
            -- hold reset state for 100 ns.    
            wait for i_clk_period*10;
    
            -- insert stimulus here 
            -- end of reset state
            i_rst <= '1';
            
            -- wait 
            wait for i_clk_period*10;
            
            -- After few ms, new data in
            i_aer_in <= x"0001";
            i_req_in <= '0';
            
            wait until o_ack_in = '0';
            
            wait for i_clk_period*2;
            
            i_req_in <= '1';
            
            wait for i_clk_period*10;
            
            -- After few ms, new data in
            i_aer_in <= x"0002";
            i_req_in <= '0';
            
            wait until o_ack_in = '0';
            
            wait for i_clk_period*2;
            
            i_req_in <= '1';
            
            wait for i_clk_period*10;
            
            wait;
        end process;



end Behavioral;
