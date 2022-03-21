library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity AER_IN is
	--generic (TAM: in integer; IL: in integer);
    Port ( i_clk : in  STD_LOGIC;
           i_rst : in  STD_LOGIC;
           --AER handshake
           i_aer_in : in  STD_LOGIC_VECTOR (15 downto 0);
           i_req_in : in  STD_LOGIC;
           o_ack_in : out  STD_LOGIC;
           --AER data output to be processed
		   o_aer_data : out STD_LOGIC_VECTOR(15 downto 0);
		   o_new_aer_data : out std_logic
		   );
end AER_IN;

architecture Behavioral of AER_IN is
	
--FSM
	type state is (reset, idle,
						capture_event, wait_REQ, remove_ACK);
	signal current_state, next_state : state;
	
	signal r_raw_aer_data : std_logic_vector(15 downto 0);
	
begin
	
	FSM_clocked : process (i_clk, i_rst)
		begin
			if i_rst = '0' then
				current_state <= reset;
				
			elsif rising_edge(i_clk) then
				current_state <= next_state;
			end if;
			
		end process FSM_clocked;
		
	FSM_transition: process(current_state, i_req_in)
	begin
		next_state <= current_state;
				
		case current_state is
			
			when reset =>
				next_state <= idle;
				
			when idle =>
				if i_req_in = '0' then
					next_state <= capture_event;
				end if;
			
			when capture_event =>
				next_state <= wait_REQ;
				
			when wait_REQ =>
				if i_req_in = '1' then
					next_state <= remove_ACK;
				end if;
				
			when remove_ACK =>
				next_state <= idle;
				
			when others =>
				next_state <= idle;
				
		end case;
	end process FSM_transition;
	
	Output_secuential : process (i_clk)
	begin
		if rising_edge(i_clk) then
			case current_state is
			
				when reset =>
					o_ack_in <= '1';
					o_new_aer_data <= '0';
					--o_aer_data <= (others => '0');
					r_raw_aer_data <= (others => '0');
					
				when capture_event =>
					o_ack_in <= '0';
					--o_aer_data <= i_aer_in;
					r_raw_aer_data <= i_aer_in;
					o_new_aer_data <= '1';
					
				when wait_REQ =>
				    o_new_aer_data <= '0';
				    
				when remove_ACK =>
					o_ack_in <= '1';
					--o_aer_data <= (others => '0');
					r_raw_aer_data <= (others => '0');
				
				when others =>
					null;
					
			end case;
		end if;
	end process Output_secuential;
	
	o_aer_data <= "0000000" & r_raw_aer_data(8 downto 0);
    
end Behavioral;