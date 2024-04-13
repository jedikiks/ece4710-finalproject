library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity Datapath is
  generic (
    PORT_ID_BITS  : integer := 32;
    OUT_PORT_BITS : integer := 32;
    IN_PORT_BITS  : integer := 32;
    FS_BITS       : integer := 5;
    DR_BITS       : integer := 4;
    SR_BITS       : integer := 4;
    MD_BITS       : integer := 2);
  port (clock, resetn : in  std_logic;
        DR            : in  std_logic_vector (DR_BITS - 1 downto 0);
        CI            : in  std_logic_vector (31 downto 0);
        DI            : in  std_logic_vector (31 downto 0);
        MD            : in  std_logic_vector (MD_BITS - 1 downto 0);
        fs            : in  std_logic_vector (FS_BITS - 1 downto 0);
        MB            : in  std_logic;
        RW            : in  std_logic;
        MA            : in  std_logic;
        MA_sclr       : in  std_logic;
        SIE           : in  std_logic;
        LIE           : in  std_logic;
        INTP          : in  std_logic;
        RI            : in  std_logic;
        RS            : in  std_logic;
        WS            : in  std_logic;
        IN_PORT       : in  std_logic_vector (IN_PORT_BITS - 1 downto 0);
        SR            : in  std_logic_vector (SR_BITS - 1 downto 0);
        Z_en          : in  std_logic;
        C_en          : in  std_logic;
        V_en          : in  std_logic;
        N_en          : in  std_logic;
        Z             : out std_logic;
        C             : out std_logic;
        V             : out std_logic;
        N             : out std_logic;
        IE            : out std_logic;
        PORT_ID       : out std_logic_vector (PORT_ID_BITS - 1 downto 0);
        --READ_STROBE   : out std_logic;
        --WRITE_STROBE  : out std_logic;
        OUT_PORT      : out std_logic_vector (OUT_PORT_BITS - 1 downto 0);
        AO            : out std_logic_vector (5 downto 0);
        DO            : out std_logic_vector (31 downto 0));
end Datapath;

architecture struct of Datapath is

  component gen_decoder is
    generic (
      NI : integer;
      NO : integer;
      EN : boolean);
    port (
      input  : in  std_logic_vector (NI - 1 downto 0);
      e      : in  std_logic;
      output : out std_logic_vector (NO - 1 downto 0));
  end component gen_decoder;

  component my_alu is
    generic (N : integer := 32);
    port (clock, resetn : in  std_logic;
          A, B          : in  std_logic_vector (N-1 downto 0);
          sel           : in  std_logic_vector (4 downto 0);
          Z_en          : in  std_logic;
          C_en          : in  std_logic;
          V_en          : in  std_logic;
          N_en          : in  std_logic;
          zflag         : out std_logic;
          cflag         : out std_logic;
          vflag         : out std_logic;
          nflag         : out std_logic;
          y             : out std_logic_vector (N-1 downto 0));
  end component;

  component my_rege is
    generic (N : integer := 4);
    port (clock, resetn : in  std_logic;
          E, sclr       : in  std_logic;  -- sclr: Synchronous clear
          D             : in  std_logic_vector (N-1 downto 0);
          Q             : out std_logic_vector (N-1 downto 0));
  end component;

  component FlipFlop is
    port (d    : in  std_logic;
          clrn : in  std_logic := '1';
          prn  : in  std_logic := '1';
          clk  : in  std_logic;
          ena  : in  std_logic;
          sclr : in  std_logic;
          q    : out std_logic);
  end component;

-- 2D array for regis output
  type dim_2 is array ((2 ** DR_BITS) - 1 downto 0) of std_logic_vector(31 downto 0);
  signal regfile_reg : dim_2;

  signal regfile_output_bus, regfile_input_bus,
    alu_out, mux_out, ma_reg_Q : std_logic_vector(31 downto 0);
  signal E : std_logic_vector (31 downto 0);


begin

  DO       <= ma_reg_Q;
  OUT_PORT <= regfile_output_bus;
  PORT_ID  <= mux_out;
  AO       <= mux_out(5 downto 0);

  with MB select
    mux_out <= regfile_output_bus when '0',
    CI                            when others;

  with MD select
    regfile_input_bus <= alu_out when "00",
    IN_PORT                      when "01",
    DI                           when others;

  -- Output register multiplexor
  regfile_output_bus <= regfile_reg(to_integer(unsigned(SR)));

  regfile_reg_sel : gen_decoder
    generic map (
      NI => DR_BITS,
      NO => 2 ** DR_BITS,
      EN => true)
    port map (
      input  => DR,
      e      => RW,
      output => E);

  alu : my_alu generic map(N => 32)
    port map(clock  => clock,
             resetn => resetn,
             A      => ma_reg_Q,
             B      => mux_out,
             sel    => fs,
             Z_en   => Z_en,
             C_en   => C_en,
             V_en   => V_en,
             N_en   => N_en,
             zflag  => Z,
             cflag => C,
             vflag => V,
             nflag => N,
             y     => alu_out);

  ieflag : FlipFlop port map (d   => SIE, clrn => '1', prn => '1',
                              clk => clock, ena => LIE, sclr => '0', q => IE);

  regfile_gen : for i in 0 to (2 ** DR_BITS) - 1 generate
    reg_i : my_rege generic map (N => 32)
      port map (clock => clock, resetn => resetn, E => E(i),
                sclr  => '0', D => regfile_input_bus, Q => regfile_reg (i));
  end generate;

  ma_reg : my_rege generic map (N => 32)
    port map (clock => clock, resetn => resetn, E => MA, sclr => MA_sclr,
              D     => regfile_output_bus, Q => ma_reg_Q);

end struct;
