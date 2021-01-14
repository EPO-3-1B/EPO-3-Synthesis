library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity stack_pointer is
	port(
			clk		: in std_logic;
			reset	: in std_logic;
			sb_s	: in std_logic; -- load from sb
			s_sb	: in std_logic; -- output to sb
			s_adl	: in std_logic; -- output to adl
			sb_in	: in std_logic_vector(7 downto 0);
			sb_out	: out std_logic_vector(7 downto 0);
			adl_out	: out std_logic_vector(7 downto 0));
end stack_pointer;

architecture behavioural of stack_pointer is

	signal q : std_logic_vector(7 downto 0); 

begin
input:	process (clk, reset, sb_s)
		begin
			if (rising_edge(clk)) then
				if (reset = '1') then
					q <= "00000000";
				elsif (reset = '0') and (sb_s = '1') then 
					q <= sb_in;
				end if;
			end if;
		end process;

output_sb:	process(s_sb)
			begin
				if (s_sb = '1') then
					sb_out  <= q;
				elsif (s_sb='0') then
					sb_out  <= "ZZZZZZZZ";
				end if;
			end  process;

output_adl:	process(s_adl)
			begin
				if (s_adl='1') then
					adl_out  <= q;
				elsif (s_adl='0') then
					adl_out  <= "ZZZZZZZZ";
				end if;
			end  process;
end behavioural;
