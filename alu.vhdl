LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY alu IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    adl_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- addres bus low in
    adl_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- addres bus low out
    sb_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- system bus in
    sb_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- system bus out
    db_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- data bus in

    -- ALU logic
    control : IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- control signals for ALU
    --bit(0) = daa, not used since decimal is not implemented
    --bit(1) = i/addc (carry in)
    --bit(2) = sums (add)
    --bit(3) = ands (and)
    --bit(4) = exors (exor)
    --bit(5) = ors (or)
    --bit(6) = srs (shift right)
    --bit(7) = sls (shift left)
    --bit(8) = rotate right
    --bit(9) = rotate left
    --bit(10) = pass1 (register a)
    --bit(11) = pass2 (register b)

    avr : OUT STD_LOGIC; -- overflow flag
    acr : OUT STD_LOGIC; -- carry out flag
    hc : OUT STD_LOGIC; -- half carry flag

    -- adder hold register
    clk_2 : IN STD_LOGIC; -- second phase clock, used as load signal
    add_adl : IN STD_LOGIC; -- output to addres low bus
    add_sb6 : IN STD_LOGIC; -- output to SB bus 0-6
    add_sb7 : IN STD_LOGIC; -- output to SB bus 7

    -- A input register
    o_add : IN STD_LOGIC; --load all 0's
    sb_add : IN STD_LOGIC; --load data from SB

    -- B input register
    inv_db_add : IN STD_LOGIC; -- load databus inverse
    db_add : IN STD_LOGIC; -- load databus
    adl_add : IN STD_LOGIC -- load addres line
  );
END ENTITY;

ARCHITECTURE structural OF alu IS
  COMPONENT alu_logic IS
    PORT (
      a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      control : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      --bit(0) = daa, not used since decimal is not implemented
      --bit(1) = i/addc (carry in)
      --bit(2) = sums (add)
      --bit(3) = ands (and)
      --bit(4) = exors (exor)
      --bit(5) = ors (or)
      --bit(6) = srs (shift right)
      --bit(7) = sls (shift left)
      --bit(8) = rotate right
      --bit(9) = rotate left
      --bit(10) = pass1 (register a)
      --bit(11) = pass2 (register b)
      o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --ALU output signal to adder hold register
      avr : OUT STD_LOGIC; --overflow flag
      acr : OUT STD_LOGIC; --carry out flag
      hc : OUT STD_LOGIC --half carry out flag, not used since decimal is not implemented
    );
  END COMPONENT;

  COMPONENT A_input_register IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      in_sb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      out_alu : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      o_add : IN STD_LOGIC; --load all 0's
      sb_add : IN STD_LOGIC --load data from SB
    );
  END COMPONENT;

  COMPONENT B_input_register IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      db : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      adl : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      out_to_alu : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      inv_db_add : IN STD_LOGIC; -- use databus inverse
      db_add : IN STD_LOGIC; -- use databus
      adl_add : IN STD_LOGIC -- use addres line
    );
  END COMPONENT;

  COMPONENT adder_hold_register IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;

      alu_data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- input from alu
      adl : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- addres low bus
      sb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- system bus

      clk_2 : IN STD_LOGIC; -- second phase clock, used as load signal
      add_adl : IN STD_LOGIC; -- output to ADL
      add_sb6 : IN STD_LOGIC; -- output to SB bus 0-6
      add_sb7 : IN STD_LOGIC -- output to SB bus 7
    );
  END COMPONENT;

  -- intermidate data signals
  SIGNAL output_alu : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL a, b : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL inv_clk : std_logic;

BEGIN

  inv_clk <= not clk;

  -- ALU logic
  alu_logicmap : alu_logic PORT MAP(
    a,
    b,
    control,
    output_alu,
    avr,
    acr,
    hc
  ); 

  -- B input register
  B_REGISTER : B_input_register PORT MAP(
    clk,
    reset,
    db_in,
    adl_in,
    b,
    inv_db_add,
    db_add,
    adl_add);

  -- A input register
  A_REGSISTER : A_input_register PORT MAP(
    clk,
    reset,
    sb_in,
    a,
    o_add,
    sb_add);

  -- adder hold register THIS IS TRIGGERED AT INV_Q1
  HOLD_REGISTER : adder_hold_register PORT MAP(
    inv_clk,
    reset,
    output_alu,
    adl_out,
    sb_out,
    clk_2,
    add_adl,
    add_sb6,
    add_sb7);

END ARCHITECTURE;
