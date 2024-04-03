library ieee;
use ieee.std_logic_1164.all;

entity program_counter is
  port (clock, resetn : in  std_logic;
        ST            : in  std_logic_vector (9 downto 0);
        SS            : in  std_logic;
        JA_CA         : in  std_logic_vector (9 downto 0);
        JS            : in  std_logic_vector (1 downto 0);
        EPC           : in  std_logic;
        E_PC          : in  std_logic;
        sclr_PC       : in  std_logic;
        PC            : out std_logic_vector (9 downto 0));
end program_counter;

architecture structure of program_counter is
  component my_rege is
    generic (N : integer := 4);
    port (clock, resetn : in  std_logic;
          E, sclr       : in  std_logic;
          D             : in  std_logic_vector (N-1 downto 0);
          Q             : out std_logic_vector (N-1 downto 0));
  end component;

  component my_addsub
    generic (N : integer := 4);
    port(addsub   : in  std_logic;
         x, y     : in  std_logic_vector (N-1 downto 0);
         s        : out std_logic_vector (N-1 downto 0);
         overflow : out std_logic;
         cout     : out std_logic);
  end component;

  signal E, overflow, cout               : std_logic;
  signal mux2_pc, mux1_pc, ADD_OUT, PC_X : std_logic_vector (9 downto 0);

begin

  E  <= EPC and E_PC;
  PC <= PC_X;

  with SS select
    mux1_pc <= PC_X when '0',
    ST              when others;

  with JS select
    mux2_pc <= JA_CA when "00",
    ST               when "01",
    "11" & x"FF"     when "10",
    ADD_OUT          when others;


  add_pc : my_addsub generic map(N => 10)
    port map(addsub => '0', x => mux1_pc, y => "0000000001", s => ADD_OUT, overflow => overflow, cout => cout);

  r_pc : my_rege generic map (N => 10)
    port map (clock => clock, resetn => resetn, E => E, sclr => sclr_PC, D => mux2_pc, Q => PC_X);

end structure;
