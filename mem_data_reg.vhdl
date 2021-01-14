--/*************************************************
--*           this is the data latch               *
--*************************************************/


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mem_data_reg is
  port (
  clk : IN std_logic;
  reset : IN std_logic;
  load : IN std_logic; -- store data from external memory into registers (control signal)

  dl_db : IN std_logic;
  dl_adl : IN std_logic;
  dl_adh : IN std_logic;

  db : OUT std_logic_vector(7 downto 0); -- to databus
  adl : OUT std_logic_vector(7 downto 0); -- addres low
  adh : OUT std_logic_vector(7 downto 0); -- addres high
  external_in : IN std_logic_vector(7 downto 0) -- external input databus
  );
end entity;

architecture arch of mem_data_reg is
  component register_8bit IS
    PORT (
      clk : IN STD_LOGIC;
      load : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      reg_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
  END component;

  -- signal  load : std_logic;
  signal data_in, reg_out : std_logic_vector(7 downto 0);
begin

  -- databus
  with dl_db select db <=
    reg_out when '1',
    "ZZZZZZZZ" when others;

  -- Addres low
  with dl_adl select adl <=
    reg_out when '1',
    "ZZZZZZZZ" when others;

  -- Addres high
  with dl_adh select adh <=
    reg_out when '1',
    "ZZZZZZZZ" when others;

  -- to register in
  with load select data_in <=
    external_in when '1',
    reg_out when others;

    l1 : register_8bit PORT MAP(clk, '1', reset, data_in, reg_out);

end architecture;
