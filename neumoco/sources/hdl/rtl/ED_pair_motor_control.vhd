----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:00:05 07/06/2019 
-- Design Name: 
-- Module Name:    ED_pair_motor_control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ED_pair_motor_control is
	Port ( 
		i_clock : in  STD_LOGIC;
		i_reset : in  STD_LOGIC;
		i_event_address : in  STD_LOGIC_VECTOR (15 downto 0);
		i_new_event_address : in  STD_LOGIC;
		o_pwm_signal_left : out  STD_LOGIC;
		o_pwm_signal_right : out  STD_LOGIC
	);
end ED_pair_motor_control;

architecture Behavioral of ED_pair_motor_control is

	--********************************
	-- Components declaration
	--********************************
	
	--
	-- PWM Generator
	--
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
	
	--********************************
	-- Constants declaration
	--********************************
	
	
	--********************************
	-- Signals declaration
	--********************************
	-- Duty cycle value for left PWM generator
	signal duty_value_left : std_logic_vector(8 downto 0);
	-- Load signal for left PWM generator
	signal new_duty_value_left : std_logic;
	
	-- Duty cycle value for right PWM generator
	signal duty_value_right : std_logic_vector(8 downto 0);
	-- Load signal for right PWM generator
	signal new_duty_value_right : std_logic;
	
	--
	signal i_event_address_shifted : STD_LOGIC_VECTOR (15 downto 0);

	begin
	
		--********************************
		-- Components instantiation
		--********************************
		
		--
		-- Left motor control
		--
		U_PWMgen_left_motor: PWM_generator
		generic map (
			CLOCK_FREQ      => 50000000,
			PWM_FREQ        => 45,--500
			DUTY_MAX        => 2000,
			DUTY_MIN        => 1000,
			SERVO_MAX_ANGLE => 256
		) 
		Port map (   
			CLK_I => i_clock,
			RST_I => i_reset,
			DUTY_I => duty_value_left,
			LOAD_I => new_duty_value_left,
			PWM_O => o_pwm_signal_left
		);
			
		--
		-- Right motor control
		--
		U_PWMgen_right_motor: PWM_generator
		generic map (
			CLOCK_FREQ      => 50000000,
			PWM_FREQ        => 45,--500
			DUTY_MAX        => 2000,
			DUTY_MIN        => 1000,
			SERVO_MAX_ANGLE => 256
		) 
		Port map (   
			CLK_I => i_clock,
			RST_I => i_reset,
			DUTY_I => duty_value_right,
			LOAD_I => new_duty_value_right,
			PWM_O => o_pwm_signal_right
		);
		
		--
		--
		--
		process(i_new_event_address, i_event_address)
		begin
			i_event_address_shifted <= std_logic_vector(shift_left(unsigned(i_event_address), 1));
		end process;
		
		process(i_new_event_address, i_event_address)
		begin
			if(i_new_event_address = '1') then
				if(i_event_address(7) = '1') then
					-- Right
					duty_value_right <= '0' & std_logic_vector(shift_left(unsigned(i_event_address(7 downto 0)), 1));--i_event_address_shifted(6 downto 0);
					new_duty_value_right <= '1';
					-- Left
					duty_value_left <= (others => '0');
					new_duty_value_left <= '0';
				else
					-- Right
					duty_value_right <= (others => '0');
					new_duty_value_right <= '0';
					-- Left
					duty_value_left <= '0' & std_logic_vector(shift_left(unsigned(i_event_address(7 downto 0)), 1));--i_event_address_shifted(6 downto 0);
					new_duty_value_left <= '1';
				end if;
			else
				-- Right
				duty_value_right <= (others => '0');
				new_duty_value_right <= '0';
				-- Left
				duty_value_left <= (others => '0');
				new_duty_value_left <= '0';
			end if;
		end process;
		
end Behavioral;

