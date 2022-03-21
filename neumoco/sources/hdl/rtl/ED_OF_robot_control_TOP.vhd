----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:35:14 07/05/2019 
-- Design Name: 
-- Module Name:    OF_motor_control_TOP - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.ED_OF_robot_control_params.all;

entity ED_OF_robot_control_TOP is
	Port ( 
		i_ext_clock 					: in  STD_LOGIC;
		i_ext_reset 					: in  STD_LOGIC;
		--Data from eDVS
		i_dvs_aer_data             : in  STD_LOGIC_VECTOR(15 downto 0);
		i_dvs_aer_req              : in  STD_LOGIC;
		o_dvs_aer_ack              : out STD_LOGIC;
		--Data from FPGA_to_SpiNN
	   o_data_out_to_spinnaker		: out STD_LOGIC_VECTOR(6 downto 0);
	   i_ack_out_from_spinnaker	: in  STD_LOGIC;
		-- Data from SpiNN_to_FPGA
		i_data_in_from_spinnaker 	: in  STD_LOGIC_VECTOR(6 downto 0);
      o_ack_in_to_spinnaker 		: out STD_LOGIC;
		--SpiNNaker IF status
		o_spinn_ui_status_active 	: out STD_LOGIC;
		o_spinn_ui_status_reset 	: out STD_LOGIC;
		o_spinn_ui_status_dump 		: out STD_LOGIC;
		o_spinn_ui_status_error 	: out STD_LOGIC;
		-- PWM output signals
		o_pwm_signal_left_motor 	: out STD_LOGIC;
		o_pwm_signal_right_motor 	: out STD_LOGIC
	);
end ED_OF_robot_control_TOP;

architecture Behavioral of ED_OF_robot_control_TOP is

	--********************************
	-- Components declaration
	--********************************

	--
	-- SpiNNaker-AER interface
	--
	component raggedstone_spinn_aer_if_top is
		port(
			ext_nreset               : in std_logic;
			ext_clk                  : in std_logic;
			--// display interface (7-segment and leds)
			ext_mode_sel             : in std_logic;
			ext_7seg                 : out std_logic_vector(7 downto 0);
			ext_strobe               : out std_logic_vector(3 downto 0);
			ext_led2                 : out std_logic;
			ext_led3                 : out std_logic;
			ext_led4                 : out std_logic;
			ext_led5                 : out std_logic;
			--// input from SpiNNaker link interface
			data_2of7_from_spinnaker : in std_logic_vector(6 downto 0);
			ack_to_spinnaker         : out std_logic;
			--// output to SpiNNaker link interface
			data_2of7_to_spinnaker   : out std_logic_vector(6 downto 0);
			ack_from_spinnaker       : in std_logic;
			--// input from AER device interface
			iaer_data                : in std_logic_vector(15 downto 0);
			iaer_req                 : in std_logic;
			iaer_ack                 : out std_logic;
			--// output to AER device interface
			oaer_data                : out std_logic_vector(15 downto 0);
			oaer_req                 : out std_logic;
			oaer_ack                 : in std_logic
		);
	end component;

	--
	-- AER In
	--
	component AER_IN is
		port(		
			i_clk          : in  std_logic;
			i_rst          : in  std_logic;
			--AER handshake
			i_aer_in       : in  std_logic_vector (15 downto 0);
			i_req_in       : in  std_logic;
			o_ack_in       : out  std_logic;
			--AER data output to be processed
			o_aer_data     : out std_logic_vector(15 downto 0);
			o_new_aer_data : out std_logic
		);
	end component;

	--
	-- ED_motor_control
	--
	component ED_pair_motor_control is
		Port ( 
			i_clock             : in  STD_LOGIC;
			i_reset             : in  STD_LOGIC;
			i_event_address     : in  STD_LOGIC_VECTOR (15 downto 0);
			i_new_event_address : in  STD_LOGIC;
			o_pwm_signal_left   : out STD_LOGIC;
			o_pwm_signal_right  : out STD_LOGIC
		);
	end component;

	--********************************
	-- Constants declaration
	--********************************

	--********************************
	-- Signals declaration
	--********************************

	--Reset signal
	signal reset   : std_logic;
	signal n_reset : std_logic;
	
	--Signals to connect AER interface from AER_OUT module to SpiNN-AER interface module
	signal aer_data_fpga_to_spinn : std_logic_vector(15 downto 0);
	signal aer_data_fpga_to_spinn_remaped : std_logic_vector(15 downto 0);
	signal aer_req_fpga_to_spinn  : std_logic;
	signal aer_ack_fpga_to_spinn  : std_logic;
	
	--Signals to connect AER interface from SpiNN-AER interface module with AER processing module
	signal aer_data_spinn_to_fpga : std_logic_vector(15 downto 0);
	signal aer_req_spinn_to_fpga  : std_logic;
	signal aer_ack_spinn_to_fpga  : std_logic;

	-- Motor control data
	signal event_data_from_spinn     : std_logic_vector(15 downto 0);
	signal new_event_data_from_spinn : std_logic;

	--Dummy signals
	signal modesel : std_logic;
	signal d_7seg  : std_logic_vector(7 downto 0);
	signal strobe  : std_logic_vector(3 downto 0);

	begin

		reset   <= i_ext_reset;
		n_reset <= not i_ext_reset;

		--TEMP
		modesel <= n_reset;
		
		--********************************
		-- Components instantiation
		--********************************
		
		--
		-- SpiNNaker driver
		--
		
		aer_data_fpga_to_spinn <= i_dvs_aer_data;
		-- Polarity
		aer_data_fpga_to_spinn_remaped(0) <= aer_data_fpga_to_spinn(8);
		-- Y-coord
		aer_data_fpga_to_spinn_remaped(7 downto 1) <= aer_data_fpga_to_spinn(6 downto 0);
		-- X-coord
		aer_data_fpga_to_spinn_remaped(14 downto 8) <= aer_data_fpga_to_spinn(15 downto 9);
		
		
		aer_req_fpga_to_spinn  <= i_dvs_aer_req;
		o_dvs_aer_ack          <= aer_ack_fpga_to_spinn;
		
		
		U_SpiNNaker_driver: raggedstone_spinn_aer_if_top
		port map(
			ext_nreset               => reset,
			ext_clk                  => i_ext_clock,
			--// display interface (7-segment and leds)
			ext_mode_sel             => modesel,
			ext_7seg                 => d_7seg,
			ext_strobe               => strobe,
			ext_led2                 => o_spinn_ui_status_active,
			ext_led3                 => o_spinn_ui_status_reset,
			ext_led4                 => o_spinn_ui_status_dump,
			ext_led5                 => o_spinn_ui_status_error,
			--// input from SpiNNaker link interface
			data_2of7_from_spinnaker => i_data_in_from_spinnaker,
			ack_to_spinnaker         => o_ack_in_to_spinnaker,
			--// output to SpiNNaker link interface
			data_2of7_to_spinnaker   => o_data_out_to_spinnaker,
			ack_from_spinnaker       => i_ack_out_from_spinnaker,
			--// input from AER device interface
			iaer_data                => aer_data_fpga_to_spinn_remaped,
			iaer_req                 => aer_req_fpga_to_spinn,
			iaer_ack                 => aer_ack_fpga_to_spinn,
			--// output to AER device interface
			oaer_data                => aer_data_spinn_to_fpga,
			oaer_req                 => aer_req_spinn_to_fpga,
			oaer_ack                 => aer_ack_spinn_to_fpga	
		);
		
		--
		-- AER IN
		--
		U_AER_in: AER_IN
		port map(
			i_clk          => i_ext_clock,
			i_rst          => reset,
			-- AER handshake
			i_aer_in       => aer_data_spinn_to_fpga,
			i_req_in       => aer_req_spinn_to_fpga,
			o_ack_in       => aer_ack_spinn_to_fpga,
			-- AER data output to be processed
			o_aer_data     => event_data_from_spinn,
			o_new_aer_data => new_event_data_from_spinn
		);
		
		--
		-- Pair motor control
		--
		U_motor_control: ED_pair_motor_control 
		port map (
			i_clock             => i_ext_clock,
			i_reset             => reset,
			-- Input events from SpiNNaker
			i_event_address     => event_data_from_spinn,
			i_new_event_address => new_event_data_from_spinn,
			-- PWM output signals
			o_pwm_signal_left   => o_pwm_signal_left_motor,
			o_pwm_signal_right  => o_pwm_signal_right_motor
		);
end Behavioral;

