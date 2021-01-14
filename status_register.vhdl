LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity status_register is
    port (
      clk : in STD_LOGIC;
      reset : in STD_LOGIC;
      --Input from bus
      db_in : in STD_LOGIC_VECTOR(7 downto 0);
      --Inputs from control
      control : in STD_LOGIC_VECTOR(14 downto 0);
      --db0_c = control(0);
      --ir5_c = control(1);
      --acr_c = control(2);
      --db1_z = control(3);
      --dbz_z = control(4);
      --db2_i = control(5);
      --ir5_i = control(6);
      --1_i   = control(7); <= This comes from interrupt logic!
      --db3_d = control(8);
      --ir5_d = control(9);
      --db6_v = control(10);
      --avr_v = control(11);
      --1_v   = control(12);
      --db7_n = control(13);

      -- databus control signal
      --p_db  = control(14)

      --Inputs from ALU
      acr   : in STD_LOGIC;
      avr   : in STD_LOGIC;

      ir5   : in STD_LOGIC;
      --Outputs
      c         : out STD_LOGIC;
      i         : out STD_LOGIC;
      db_out    : out STD_LOGIC_VECTOR(7 downto 0)
    );
END ENTITY;

ARCHITECTURE behaviour of status_register is

  COMPONENT register_8bit IS
    PORT (
      clk : IN STD_LOGIC;
      load : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      reg_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
  END COMPONENT;

signal reg_out : STD_LOGIC_VECTOR(7 downto 0); --intermediate signals
signal reg_in : STD_LOGIC_VECTOR(7 downto 0);

signal dbz  : STD_LOGIC;

BEGIN


--Creating the DBZ signal (Databus Zero)
dbz <= not (db_in(0) or db_in(1) or db_in(2) or db_in(3) or db_in(4) or db_in(5) or db_in(6) or db_in(7));


--bit 0
  -- C FLAG
WITH control(2 downto 0) SELECT reg_in(0) <=
db_in(0)    WHEN "001", -- DB0/C
ir5         WHEN "010", -- IR5/C
acr         WHEN "100", -- ACR/C
reg_out(0) WHEN OTHERS;


--bit 1
  -- Z FLAG
WITH control(4 downto 3) SELECT reg_in(1) <=
db_in(1)    WHEN "01", -- DBI/Z
dbz         WHEN "10", -- DBZ/Z
reg_out (1) WHEN OTHERS;


--bit 2
  -- I FLAG
WITH control(7 downto 5) SELECT reg_in(2) <=
db_in(2) 	 WHEN "001", -- DB2/I
ir5        WHEN "010", -- IR5/I
'1'        WHEN "100", -- 1/I
reg_out(2) WHEN OTHERS;


--bit 3
  -- D FLAG
WITH control(9 downto 8) SELECT reg_in(3) <=
db_in(3)    WHEN "01", -- DB3/D
ir5         WHEN "10", -- IR5/D
reg_out(3)  WHEN OTHERS;

--bit 4 and 5 are "dont care"
  --'0' has been chosen as their value
reg_in(4) <= '0';
reg_in(5) <= '0';


--bit 6
  --V FLAG
WITH control(12 downto 10) SELECT reg_in(6) <=
db_in (6)   WHEN "001",   -- DB6/V
acr         WHEN "010", -- AVR/V
'1'  WHEN "100", -- 1/V,
reg_out (6) WHEN OTHERS;


--bit 7
  -- N FLAG
  -- DB7/N
WITH control(13) SELECT reg_in(7) <=
db_in(7)   WHEN '1',
reg_out(7)  WHEN OTHERS;

-- out to databus
WITH control(14) SELECT db_out <=
reg_out when '1',
"ZZZZZZZZ" WHEN OTHERS;

--port bit 0 and 2 to a seperate output
c <= reg_out(0);
i <= reg_out(2);

l1 : register_8bit PORT MAP(clk, '1', reset, reg_in, reg_out);

 end behaviour;
