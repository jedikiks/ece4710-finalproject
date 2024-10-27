library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
  generic (
    ADDR_WDTH   : integer := 10;
    OFFSET_WDTH : integer := 10);
  port (clock, resetn : in  std_logic;
        ST            : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
        SS            : in  std_logic_vector (1 downto 0);
        offset        : in  std_logic_vector (OFFSET_WDTH - 1 downto 0);
        JA_CA         : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
        JS            : in  std_logic_vector (2 downto 0);
        EPC           : in  std_logic;
        E_PC          : in  std_logic;
        sclr_PC       : in  std_logic;
        PC            : out std_logic_vector (ADDR_WDTH - 1 downto 0));
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

  signal E, overflow, cout                               : std_logic;
  signal mux2_pc, mux1_pc, ADD_OUT, PC_X                 : std_logic_vector (ADDR_WDTH - 1 downto 0);
  signal offset_sign_ex, pc_sign_ext, offset_add_out : std_logic_vector (ADDR_WDTH downto 0);

begin
  offset_sign_ex  <= std_logic_vector(resize(signed(offset), ADDR_WDTH + 1));
  pc_sign_ext <= '0' & PC_X;
  E               <= EPC and E_PC;
  PC              <= PC_X;

  with SS select
    mux1_pc <= PC_X when "00",
    ST              when others;

  with JS select
    mux2_pc <= JA_CA                                                    when "000",
    ST                                                                  when "001",
    std_logic_vector(to_unsigned((2 ** ADDR_WDTH) - 1, mux2_pc'length)) when "010",
    ADD_OUT                                                             when "011",
    offset_add_out(ADDR_WDTH - 1 downto 0)                              when others;


  add_pc : my_addsub generic map(N => ADDR_WDTH)
    port map(addsub => '0', x => mux1_pc, y => std_logic_vector(to_unsigned(1, ADDR_WDTH)),
             s      => ADD_OUT, overflow => overflow, cout => cout);

  add_pc_offset : my_addsub
    generic map (
      N => ADDR_WDTH + 1)
    port map (
      addsub   => '0',
      x        => offset_sign_ex,
      y        => pc_sign_ext,
      s        => offset_add_out,
      overflow => overflow,
      cout     => cout);

  r_pc : my_rege generic map (N => ADDR_WDTH)
    port map (clock => clock, resetn => resetn, E => E, sclr => sclr_PC, D => mux2_pc, Q => PC_X);

end structure;
