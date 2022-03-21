----------------------------------------------------------------------------------
-- Company: Universidad de Cadiz
-- Engineer: Fernando Perez
-- Modified by: Daniel Gutierrez-Galan
-- From: University of Seville
-- 
-- Create Date: 15.06.2018 19:03:58
-- Modified Date: 05.07.2019 9:50
--
-- Design Name: PWM module for the Hexapod project 
-- Module Name: Neuro_PWM - Behavioral
-- Project Name: NeuroPod
-- Target Devices: Not matched to any device
-- Tool Versions: 
-- Description: This module generates a PWM signal for a standard servo motor (0-180 degrees). 
-- The signals is generated according to two inputs: if a positive spike (digital pulse) is received, the PWM signal generates a move forward command.
-- And the oppossite if a negative spike is received. The reset position can be configurable. These three positions are configurable by means of generics. 
-- The parameters to be configured are: the PWM frequency, the HOME, FORWARD and BACKWARDS angles. The maximun and minimum duty cycle in us   
-- The mdoule has two down counters: one to generate the main PWM signal and the other one to generate the duty cycle for the messagge. 
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

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PWM_generator is
	generic (
		CLOCK_FREQ      : INTEGER := 50000000; --this value is expressed in Hz
		PWM_FREQ	       : INTEGER := 45;			--this value is expressed in Hz
		DUTY_MAX        : INTEGER := 2000;     --this value is expressed in us
		DUTY_MIN        : INTEGER := 1000;     --this value is expressed in us
		SERVO_MAX_ANGLE : INTEGER := 256
	); 
	Port (   
		CLK_I      : in  STD_LOGIC;
		RST_I      : in  STD_LOGIC;
		DUTY_I     : in  STD_LOGIC_VECTOR(8 downto 0);
		LOAD_I     : in  STD_LOGIC;
		PWM_O      : out STD_LOGIC
	);
end PWM_generator;

architecture Behavioral of PWM_generator is

constant OFFSET1: INTEGER:=CLOCK_FREQ/1000000;
constant OFFSET: INTEGER:=OFFSET1*DUTY_MIN;
--constant test_value : STD_LOGIC_VECTOR(8 downto 0) := "001111111";

signal PWM_register : INTEGER RANGE 0 to CLOCK_FREQ/PWM_FREQ; --This is the register used for the down-counter. The range is assumed to be from the lowest value PWM_BKWD to highest value PWM_FWD
signal counter_duty : INTEGER RANGE 0 to CLOCK_FREQ/PWM_FREQ;
signal counter_PWM  : INTEGER RANGE 0 to CLOCK_FREQ/PWM_FREQ;

constant period_PWM : INTEGER:=CLOCK_FREQ/PWM_FREQ; --The division between the clock_freq and the pwm freq will give the number of clock cycles to count

signal update_duty_cycle: STD_LOGIC;

function f_DutyCycle_to_PWMval(arg_Duty_in : STD_LOGIC_VECTOR(8 downto 0)) return INTEGER is
	variable v_pwmval : integer;
begin
	v_pwmval := (OFFSET1*conv_integer(unsigned(arg_Duty_in))*(DUTY_MAX-DUTY_MIN))/(SERVO_MAX_ANGLE) + OFFSET;
	return v_pwmval;
end; 

begin

main_process: process (CLK_I, RST_I)
begin
		if (RST_I = '0') then
			PWM_register <= 0;--f_DutyCycle_to_PWMval(test_value);--0;
		elsif rising_edge(CLK_I) then
			if LOAD_I = '1' then 
				PWM_register <= f_DutyCycle_to_PWMval(DUTY_I);
			else
			
			end if;
		else
		
		end if;
end process main_process;

--considering a clock frequency of 48 MHz, that means a period of 20,83ns
duty_counter: process (CLK_I, RST_I)
begin
	if (RST_I = '0') then 
		counter_duty <= 0; 
		PWM_O        <= '0';
	elsif rising_edge(CLK_I) then 
		if (update_duty_cycle ='1') then
			counter_duty <= PWM_register;
		else
		
		end if; 
		if (counter_duty > 0) then 
			counter_duty <= counter_duty - 1;
			PWM_O        <= '1';
		else
			PWM_O        <= '0';
		end if; 	
	else
	
	end if; 		
	
end process duty_counter;	

PWM_period: process (CLK_I, RST_I)
begin 
	if (RST_I = '0') then 
		counter_PWM       <= period_PWM;
		update_duty_cycle <= '0'; 
	elsif rising_edge(CLK_I) then 
		if (counter_PWM = 0) then 
			update_duty_cycle <= '1'; 
			counter_PWM       <= period_PWM;
		else
			counter_PWM <= counter_PWM-1;
			update_duty_cycle <= '0';
		end if;
	else
	
	end if; 

end process PWM_period;

end Behavioral;

