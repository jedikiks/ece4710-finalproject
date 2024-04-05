library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack is
  generic (
    SP_WDTH  : integer := 5;
    DAT_WDTH : integer := 16);
  port (
    we, en, sclr, clock, resetn : in  std_logic;
    DI                          : in  std_logic_vector (DAT_WDTH - 1 downto 0);
    DO                          : out std_logic_vector (DAT_WDTH - 1 downto 0);
    SP                          : out std_logic_vector (SP_WDTH - 1 downto 0));
end stack;

architecture structural of stack is

  component ram_emul_output is
    generic (
      DI_WDTH   : integer;
      DO_WDTH   : integer;
      ADDR_WDTH : integer;
      OMUX_NOTZ : boolean);
    port (
      clock, resetn, we, en   : in  std_logic;
      di                      : in  std_logic_vector (DI_WDTH - 1 downto 0);
      address_in, address_out : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
      do                      : out std_logic_vector (DO_WDTH - 1 downto 0));
  end component ram_emul_output;

  component my_addsub
    generic (N : integer := 4);
    port(addsub   : in  std_logic;
         x, y     : in  std_logic_vector (N-1 downto 0);
         s        : out std_logic_vector (N-1 downto 0);
         overflow : out std_logic;
         cout     : out std_logic);
  end component;

  component my_rege
    generic (N : integer := 4);
    port (clock, resetn : in  std_logic;
          E, sclr       : in  std_logic;
          D             : in  std_logic_vector (N-1 downto 0);
          Q             : out std_logic_vector (N-1 downto 0));
  end component;

  signal addsub_res, addsub_0or1, addr_muxout, sp_t,
    sp_in, spt_newval : std_logic_vector (SP_WDTH - 1 downto 0);
  signal empty, spt_sel : std_logic;

begin
  SP      <= sp_t;
  spt_sel <= (we and en) or (not empty and en);

  -- reset/new value multiplexor
  with sclr select
    sp_in <= std_logic_vector(to_unsigned(2**SP_WDTH - 1, SP_WDTH)) when '1',
    spt_newval                                                      when others;

  -- enable/empty/we multiplexor
  with spt_sel select
    spt_newval <= addsub_res when '1',
    sp_t                     when others;

  -- empty comparator
  empty <= '1' when sp_t = std_logic_vector(to_unsigned(2**SP_WDTH - 1, SP_WDTH)) else '0';

  my_rege_1 : my_rege
    generic map (
      N => SP_WDTH)
    port map (
      clock  => clock,
      resetn => resetn,
      E      => en,
      sclr   => '0',
      D      => SP_in,
      Q      => sp_t);

  my_addsub_1 : my_addsub
    generic map (
      N => SP_WDTH)
    port map (
      addsub => we,
      x      => sp_t,
      y      => std_logic_vector(to_unsigned(1, SP_WDTH)),
      s      => addsub_res);

  ram_emul_output_1 : ram_emul_output
    generic map (
      DI_WDTH   => DAT_WDTH,
      DO_WDTH   => DAT_WDTH,
      ADDR_WDTH => SP_WDTH,
      OMUX_NOTZ => false)
    port map (
      clock       => clock,
      resetn      => resetn,
      we          => we,
      en          => en,
      di          => DI,
      address_in  => spt_newval,
      address_out => sp_t,
      do          => DO);

end structural;
