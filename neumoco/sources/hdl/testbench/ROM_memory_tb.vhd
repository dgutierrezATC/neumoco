--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:11:30 07/05/2019
-- Design Name:   
-- Module Name:   D:/Proyectos/Universidad/Doctorado/Motor_control/v1/Sources/ROM_memory_tb.vhd
-- Project Name:  OF_motor_control
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ROM_memory
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ROM_memory_tb IS
END ROM_memory_tb;
 
ARCHITECTURE behavior OF ROM_memory_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT ROM_memory
	GENERIC (
		g_NBITS_DATA : INTEGER := 8;
		g_NWORDS : INTEGER := 4;
		g_NWORDS_ADDRESS_NBITS : INTEGER := 2
	);
	PORT(
		i_address : IN  std_logic_vector(1 downto 0);
		o_data : OUT  std_logic_vector(7 downto 0)
		);
	END COMPONENT;
    

   --Inputs
   signal i_address : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal o_data : std_logic_vector(7 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
	signal tb_clock : std_logic := '0';
 
   constant tb_clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ROM_memory 
	GENERIC MAP (
		g_NBITS_DATA => 8,
		g_NWORDS => 4,
		g_NWORDS_ADDRESS_NBITS => 2
	)
	PORT MAP (
		i_address => i_address,
		o_data => o_data
	);

   -- Clock process definitions
   tb_clock_process :process
   begin
		tb_clock <= '0';
		wait for tb_clock_period/2;
		tb_clock <= '1';
		wait for tb_clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- insert stimulus here 
		
		i_address <= "00";
		wait for 100 ns;
		
		i_address <= "01";
		wait for 100 ns;
		
		i_address <= "10";
		wait for 100 ns;
		
		i_address <= "11";
		wait for 100 ns;
      wait;
   end process;

END;
