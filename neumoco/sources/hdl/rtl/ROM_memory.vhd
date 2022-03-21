----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:02:01 07/05/2019 
-- Design Name: 
-- Module Name:    ROM_memory - Behavioral 
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

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ROM_memory is
	Generic (
		g_NBITS_DATA : INTEGER := 8;
		g_NWORDS : INTEGER := 4;
		g_NWORDS_ADDRESS_NBITS : INTEGER := 2
	);
	Port ( 
		i_address : in  STD_LOGIC_VECTOR ((g_NWORDS_ADDRESS_NBITS-1) downto 0);
		o_data : out  STD_LOGIC_VECTOR ((g_NBITS_DATA-1) downto 0)
	);
end ROM_memory;

architecture Behavioral of ROM_memory is

	TYPE vector_array IS ARRAY (0 TO (g_NWORDS-1)) of STD_LOGIC_VECTOR((g_NBITS_DATA-1) downto 0);
	
	CONSTANT memory : vector_array := (
		"00000001",
		"00000010",
		"00000100",
		"00001000"
	);

begin

	o_data <= memory(conv_integer(unsigned(i_address)));
	
end Behavioral;
	