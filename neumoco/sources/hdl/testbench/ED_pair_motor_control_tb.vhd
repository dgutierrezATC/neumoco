--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:30:04 07/06/2019
-- Design Name:   
-- Module Name:   D:/Proyectos/Universidad/Doctorado/Motor_control/v1/Sources/ED_pair_motor_control_tb.vhd
-- Project Name:  ED_pair_motor_control
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ED_pair_motor_control
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY ED_pair_motor_control_tb IS
END ED_pair_motor_control_tb;
 
ARCHITECTURE behavior OF ED_pair_motor_control_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ED_pair_motor_control
    PORT(
         i_clock : IN  std_logic;
         i_reset : IN  std_logic;
         i_event_address : IN  std_logic_vector(15 downto 0);
         i_new_event_address : IN  std_logic;
         o_pwm_signal_left : OUT  std_logic;
         o_pwm_signal_right : OUT  std_logic
	 );
    END COMPONENT;
    

   --Inputs
   signal i_clock : std_logic := '0';
   signal i_reset : std_logic := '0';
   signal i_event_address : std_logic_vector(15 downto 0) := (others => '0');
   signal i_new_event_address : std_logic := '0';

 	--Outputs
   signal o_pwm_signal_left : std_logic;
   signal o_pwm_signal_right : std_logic;

   -- Clock period definitions
   constant i_clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ED_pair_motor_control PORT MAP (
          i_clock => i_clock,
          i_reset => i_reset,
          i_event_address => i_event_address,
          i_new_event_address => i_new_event_address,
          o_pwm_signal_left => o_pwm_signal_left,
          o_pwm_signal_right => o_pwm_signal_right
	);

   -- Clock process definitions
   i_clock_process :process
   begin
		i_clock <= '0';
		wait for i_clock_period/2;
		i_clock <= '1';
		wait for i_clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
		--Local variables
		variable v_inevent : integer := 0;
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		i_reset <= '1';

      wait for 200 ms;

      -- insert stimulus here 
--		i_event_address <= "0000000011111111";
--		i_new_event_address <= '1';
--		wait for i_clock_period;
--		i_new_event_address <= '0';
--		
--		wait for 200 ms;
--		
--		i_event_address <= "0000000100000000";
--		i_new_event_address <= '1';
--		wait for i_clock_period;
--		i_new_event_address <= '0';
--		
--		wait for 300 ms;
--		
--		i_event_address <= "0000000011000000";
--		i_new_event_address <= '1';
--		wait for i_clock_period;
--		i_new_event_address <= '0';
--		
--		wait for 1 ms;
--		
--		i_event_address <= "0000000111000000";
--		i_new_event_address <= '1';
--		wait for i_clock_period;
--		i_new_event_address <= '0';
--		
--		wait for 1000 ms;

		-- For loop to test the PWM generator
		 for t_angle in 250 to 260 loop
			
			 v_inevent := t_angle;
			 i_event_address <= std_logic_vector(to_unsigned(v_inevent, i_event_address'length));

			 i_new_event_address <= '1';
			 wait for i_clock_period;
			 i_new_event_address <= '0';

			 wait for 100 ms;
		 end loop;
		
      wait;
   end process;

END;
