LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_8bit_C IS
	PORT (
		clk : IN STD_LOGIC;
		load : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		reg_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END register_8bit_C;

ARCHITECTURE behaviour OF register_8bit_C IS

	SIGNAL q : STD_LOGIC_VECTOR (7 DOWNTO 0); --adding intermediate signal for output register

BEGIN
	PROCESS (clk, reset, load) --process to determine output register
	BEGIN
		IF (rising_edge(clk)) THEN --both need to be high to load value from bus
			IF (reset = '1') THEN
				q <= "10101010"; --clears the value in q
			ELSIF (reset = '0') and (load = '1') THEN
				q <= data_in; --data from bus stored in q
			END IF;
		END IF;
	END PROCESS;
reg_out <= q;
END behaviour;
