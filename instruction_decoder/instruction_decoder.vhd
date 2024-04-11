library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder is
  generic (
    IR_BITS : integer := 18;
    -- Datapath
    FS_BITS : integer := 5;
    DR_BITS : integer := 4;
    SR_BITS : integer := 4;
    MD_BITS : integer := 2);
  port (
    IR                                              : in  std_logic_vector (IR_BITS - 1 downto 0);
    clock, resetn, INT, Z, V, N, C
    IE, E_PC                                        : in  std_logic;
    INT_ACK                                         : out std_logic;
    -- Program Counter Signals
    JS                                              : out std_logic_vector (1 downto 0);
    EPC, SS                                         : out std_logic;
    -- Datapath Signals
    DR                                              : out std_logic_vector (DR_BITS - 1 downto 0);
    SR                                              : out std_logic_vector (SR_BITS - 1 downto 0);
    MD                                              : out std_logic_vector (MD_BITS - 1 downto 0);
    fs                                              : out std_logic_vector (FS_BITS - 1 downto 0);
    RW, MA, MA_sclr, SIE, LIE, INTP, RI, RS, WS, MB : out std_logic;
    -- Data Memory Signals
    DM_WE                                           : out std_logic;
    -- Stack Signals
    we, en, sclr                                    : out std_logic);
end instruction_decoder;

architecture structural of instruction_decoder is
  component id_fsm is
    generic (
      IR_BITS : integer;
      FS_BITS : integer;
      DR_BITS : integer;
      SR_BITS : integer;
      MD_BITS : integer);
    port (
      IR                                         : in  std_logic_vector (IR_BITS - 1 downto 0);
      clock, resetn, Z, V, N, C, IE, E_PC, INT_P : in  std_logic;
      INT_ACK                                    : out std_logic;

      JS                                              : out std_logic_vector (1 downto 0);
      EPC, SS                                         : out std_logic;
      DR                                              : out std_logic_vector (DR_BITS - 1 downto 0);
      SR                                              : out std_logic_vector (SR_BITS - 1 downto 0);
      MD                                              : out std_logic_vector (MD_BITS - 1 downto 0);
      fs                                              : out std_logic_vector (FS_BITS - 1 downto 0);
      RW, MA, MA_sclr, SIE, LIE, INTP, RI, RS, WS, MB : out std_logic;
      DM_WE                                           : out std_logic;
      we, en, sclr                                    : out std_logic);
  end component id_fsm;

  component interrupt_fsm is
    port (clock, resetn, INT, IE : in  std_logic;
          INT_P                  : out std_logic);
  end component interrupt_fsm;

  signal INT_P : std_logic;

begin

  INTP <= INT_P;

  id_fsm_1 : id_fsm
    generic map (
      IR_BITS => IR_BITS,
      FS_BITS => FS_BITS,
      DR_BITS => DR_BITS,
      SR_BITS => SR_BITS,
      MD_BITS => MD_BITS)
    port map (
      IR      => IR,
      clock   => clock,
      resetn  => resetn,
      Z       => Z,
      V       => V,
      N       => N,
      C       => C,
      IE      => IE,
      INT_P   => INT_P,
      INT_ACK => INT_ACK,
      E_PC    => E_PC,
      JS      => JS,
      EPC     => EPC,
      SS      => SS,
      DR      => DR,
      SR      => SR,
      MD      => MD,
      fs      => fs,
      RW      => RW,
      MA      => MA,
      MA_sclr => MA_sclr,
      SIE     => SIE,
      LIE     => LIE,
      INTP    => INTP,
      RI      => RI,
      RS      => RS,
      WS      => WS,
      MB      => MB,
      DM_WE   => DM_WE,
      we      => we,
      en      => en,
      sclr    => sclr);

  interrupt_fsm_1 : interrupt_fsm
    port map (
      clock  => clock,
      resetn => resetn,
      INT    => INT,
      IE     => IE,
      INT_P  => INT_P);

end structural;
