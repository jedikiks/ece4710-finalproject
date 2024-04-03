library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Datapath is
  generic (
    PORT_ID_BITS  : integer := 8;
    OUT_PORT_BITS : integer := 8;
    IN_PORT_BITS  : integer := 8;
    FS_BITS       : integer := 5;
    DR_BITS       : integer := 4;
    SR_BITS       : integer := 4;
    MD_BITS       : integer := 2);
  port (clock, resetn : in  std_logic;
        DR            : in  std_logic_vector (DR_BITS - 1 downto 0);
        CI            : in  std_logic_vector (7 downto 0);
        DI            : in  std_logic_vector (7 downto 0);
        MD            : in  std_logic_vector (MD_BITS - 1 downto 0);
        fs            : in  std_logic_vector (FS_BITS - 1 downto 0);
        MB            : in  std_logic;
        RW            : in  std_logic;
        MA            : in  std_logic;
        SIE           : in  std_logic;
        LIE           : in  std_logic;
        INTP          : in  std_logic;
        RI            : in  std_logic;
        RS            : in  std_logic;
        WS            : in  std_logic;
        IN_PORT       : in  std_logic_vector (IN_PORT_BITS - 1 downto 0);
        SR            : in  std_logic_vector (SR_BITS - 1 downto 0);
        Z             : out std_logic;
        C             : out std_logic;
        V             : out std_logic;
        N             : out std_logic;
        IE            : out std_logic;
        PORT_ID       : out std_logic_vector (PORT_ID_BITS - 1 downto 0);
        READ_STROBE   : out std_logic;
        WRITE_STROBE  : out std_logic;
        OUT_PORT      : out std_logic_vector (OUT_PORT_BITS - 1 downto 0);
        AO            : out std_logic_vector (5 downto 0);
        DO            : out std_logic_vector (7 downto 0));
end Datapath;

architecture struct of Datapath is

  component mydec4to16 is
    port (DR : in  std_logic_vector (3 downto 0);
          RW : in  std_logic;
          E  : out std_logic_vector (15 downto 0));
  end component;

  component my_alu is
    generic (N : integer := 8);
    port (clock, resetn : in  std_logic;
          A, B          : in  std_logic_vector (N-1 downto 0);
          sel           : in  std_logic_vector (4 downto 0);
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

  signal reg_out, xz, alu_out, mux_out, r_16_out, r_15_out, r_14_out, r_13_out, r_12_out, r_11_out, r_10_out,
    r_9_out, r_8_out, r_7_out, r_6_out, r_5_out, r_4_out, r_3_out, r_2_out, r_1_out, r_0_out : std_logic_vector(7 downto 0);
  signal E : std_logic_vector (15 downto 0);


begin

  ieflag : FlipFlop port map (d => SIE, clrn => '1', prn => '1', clk => clock, ena => LIE, sclr => '0', q => IE);


  DO       <= reg_out;
  OUT_PORT <= reg_out;
  PORT_ID  <= mux_out;
  AO       <= mux_out(5 downto 0);

  alu : my_alu generic map(N => 8)
    port map(clock => clock, resetn => resetn, A => r_16_out, B => mux_out, sel => fs, zflag => Z,
             cflag => C, vflag => V, nflag => N, y => alu_out);

  dec : mydec4to16 port map(DR => DR, RW => RW, E => E);

  with MB select
    mux_out <= reg_out when '0',
    CI                 when others;

  with MD select
    xz <= alu_out when "00",
    IN_PORT       when "01",
    DI            when others;


  with SR select
    reg_out <= r_0_out when "0000",
    r_1_out            when "0001",
    r_2_out            when "0010",
    r_3_out            when "0011",
    r_4_out            when "0100",
    r_5_out            when "0101",
    r_6_out            when "0110",
    r_7_out            when "0111",
    r_8_out            when "1000",
    r_9_out            when "1001",
    r_10_out           when "1010",
    r_11_out           when "1011",
    r_12_out           when "1100",
    r_13_out           when "1101",
    r_14_out           when "1110",
    r_15_out           when others;

  r_16 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => MA, sclr => '0', D => reg_out, Q => r_16_out);
  r_15 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(15), sclr => '0', D => xz, Q => r_15_out);
  r_14 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(14), sclr => '0', D => xz, Q => r_14_out);
  r_13 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(13), sclr => '0', D => xz, Q => r_13_out);
  r_12 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(12), sclr => '0', D => xz, Q => r_12_out);
  r_11 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(11), sclr => '0', D => xz, Q => r_11_out);
  r_10 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(10), sclr => '0', D => xz, Q => r_10_out);
  r_9 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(9), sclr => '0', D => xz, Q => r_9_out);
  r_8 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(8), sclr => '0', D => xz, Q => r_8_out);
  r_7 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(7), sclr => '0', D => xz, Q => r_7_out);
  r_6 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(6), sclr => '0', D => xz, Q => r_6_out);
  r_5 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(5), sclr => '0', D => xz, Q => r_5_out);
  r_4 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(4), sclr => '0', D => xz, Q => r_4_out);
  r_3 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(3), sclr => '0', D => xz, Q => r_3_out);
  r_2 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(2), sclr => '0', D => xz, Q => r_2_out);
  r_1 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(1), sclr => '0', D => xz, Q => r_1_out);
  r_0 : my_rege generic map (N => 8)
    port map (clock => clock, resetn => resetn, E => E(0), sclr => '0', D => xz, Q => r_0_out);


end struct;
