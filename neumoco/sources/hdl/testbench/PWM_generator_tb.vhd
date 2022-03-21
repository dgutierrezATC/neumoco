--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:48:26 07/05/2019
-- Design Name:   
-- Module Name:   D:/Proyectos/Universidad/Doctorado/Motor_control/v1/Sources/PWM_generator_tb.vhd
-- Project Name:  OF_motor_control
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PWM_generator
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
 
ENTITY PWM_generator_tb IS
END PWM_generator_tb;
 
ARCHITECTURE behavior OF PWM_generator_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)
 
	component PWM_generator is
	generic (
		CLOCK_FREQ      : INTEGER := 50000000; --this value is expressed in Hz
		PWM_FREQ	       : INTEGER := 45;			--this value is expressed in Hz
		DUTY_MAX        : INTEGER := 2000;     --this value is expressed in us
		DUTY_MIN        : INTEGER := 1000;     --this value is expressed in us
		SERVO_MAX_ANGLE : INTEGER := 256
	); 
	Port (   
		CLK_I 					: in STD_LOGIC;
		RST_I 					: in STD_LOGIC;
		DUTY_I					: in STD_LOGIC_VECTOR(8 downto 0);
		LOAD_I					: in STD_LOGIC;
		PWM_O						: out STD_LOGIC
	);
	end component;
    

	--Inputs
	signal CLK_I 	: std_logic 								:= '0';
	signal RST_I 	: std_logic 								:= '0';
	signal DUTY_I 	: std_logic_vector(8 downto 0) 		:= (others => '0');
	signal LOAD_I 	: std_logic 								:= '0';

	--Outputs
	signal PWM_O 	: std_logic;
	
	

	-- Clock period definitions
	constant CLK_I_period : time := 20 ns;
 
	BEGIN
 
		-- Instantiate the Unit Under Test (UUT)
		uut: PWM_generator 
		GENERIC MAP (
			CLOCK_FREQ      => 50000000,
			PWM_FREQ        => 45,--500
			DUTY_MAX        => 2000,
			DUTY_MIN        => 1000,
			SERVO_MAX_ANGLE => 256
		) 
		PORT MAP (
			CLK_I  => CLK_I,
			RST_I  => RST_I,
			DUTY_I => DUTY_I,
			LOAD_I => LOAD_I,
			PWM_O  => PWM_O
        );

		-- Clock process definitions
		CLK_I_process :process
		begin
			CLK_I <= '0';
			wait for CLK_I_period/2;
			CLK_I <= '1';
		wait for CLK_I_period/2;
		end process;
 

		-- Stimulus process
		stim_proc: process
			--Local variables
			variable v_DUTY_VAL : integer := 0;
		begin		
			-- hold reset state for 100 ns.
			wait for 100 ns;	

			RST_I <= '1';

			wait for CLK_I_period*10;

			-- insert stimulus here 

			-- hold reset PWM value
			wait for 100 ms;

			-- For loop to test the PWM generator
			 for t_angle in 254 to 255 loop
				
				 v_DUTY_VAL := t_angle;
				 DUTY_I <= std_logic_vector(to_unsigned(v_DUTY_VAL, DUTY_I'length));

				 LOAD_I <= '1';
				 wait for CLK_I_period;
				 LOAD_I <= '0';

				 wait for 100 ms;
			 end loop;
			
			wait;
		end process;
END;
