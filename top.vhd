library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity top is
  generic (
    -- Instruction Memory
    IM_DIN_BITS   : integer;
    IM_ADDR_BITS  : integer;
    -- Data Memory
    DI_WDTH       : integer;
    DO_WDTH       : integer;
    ADDR_WDTH     : integer;
    -- Stack
    SP_WDTH       : integer;
    DAT_WDTH      : integer;
    -- Control
    IR_BITS       : integer;
    -- Datapath
    FS_BITS       : integer;
    DR_BITS       : integer;
    SR_BITS       : integer;
    MD_BITS       : integer;
    PORT_ID_BITS  : integer;
    OUT_PORT_BITS : integer;
    IN_PORT_BITS  : integer);

  port (
    -- Input signals
    clock, resetn, INT        : in  std_logic;
    -- PC signals
    E_PC, sclr_PC             : in  std_logic;
    -- IM signals
    im_enb, im_web            : in  std_logic;
    im_dinb                   : in  std_logic_vector (IM_DIN_BITS - 1 downto 0);
    im_addrb                  : in  std_logic_vector (IM_ADDR_BITS - 1 downto 0);
    -- Output signals
    IN_PORT                   : in  std_logic_vector (IN_PORT_BITS - 1 downto 0);
    READ_STROBE, WRITE_STROBE : out std_logic;
    PORT_ID                   : out std_logic_vector (PORT_ID_BITS - 1 downto 0);
    OUT_PORT                  : out std_logic_vector (OUT_PORT_BITS - 1 downto 0));
end top;

architecture structural of top is
  component Datapath is
    generic (
      PORT_ID_BITS  : integer;
      OUT_PORT_BITS : integer;
      IN_PORT_BITS  : integer;
      FS_BITS       : integer;
      DR_BITS       : integer;
      SR_BITS       : integer;
      MD_BITS       : integer);
    port (
      clock, resetn : in  std_logic;
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
      DO            : out std_logic_vector (31 downto 0));
  end component Datapath;

  component instr_mem is
    port (
      clka  : in  std_logic;
      ena   : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(9 downto 0);
      dina  : in  std_logic_vector(31 downto 0);
      douta : out std_logic_vector(31 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(9 downto 0);
      dinb  : in  std_logic_vector(31 downto 0);
      doutb : out std_logic_vector(31 downto 0)
      );
  end component instr_mem;

  component stack is
    generic (
      SP_WDTH  : integer;
      DAT_WDTH : integer);
    port (
      we, en, sclr, clock, resetn : in  std_logic;
      DI                          : in  std_logic_vector (DAT_WDTH - 1 downto 0);
      DO                          : out std_logic_vector (DAT_WDTH - 1 downto 0);
      SP                          : out std_logic_vector (SP_WDTH - 1 downto 0));
  end component stack;

  component instruction_decoder is
    generic (
      -- Control
      IR_BITS : integer := 18;
      -- Datapath
      FS_BITS : integer := 5;
      DR_BITS : integer := 4;
      SR_BITS : integer := 4;
      MD_BITS : integer := 2);
    port (
      IR                                              : in  std_logic_vector (IR_BITS - 1 downto 0);
      clock, resetn, INT, Z, V, N, C,
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
  end component instruction_decoder;

  component program_counter is
    generic (
      ADDR_WDTH : integer);
    port (
      clock, resetn : in  std_logic;
      ST            : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
      SS            : in  std_logic;
      JA_CA         : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
      JS            : in  std_logic_vector (1 downto 0);
      EPC           : in  std_logic;
      E_PC          : in  std_logic;
      sclr_PC       : in  std_logic;
      PC            : out std_logic_vector (IM_ADDR_BITS - 1 downto 0));
  end component program_counter;

  component ram_emul is
    generic (
      DI_WDTH   : integer;
      DO_WDTH   : integer;
      ADDR_WDTH : integer;
      OMUX_NOTZ : boolean);
    port (
      clock, resetn, we, en : in  std_logic;
      di                    : in  std_logic_vector (DI_WDTH - 1 downto 0);
      address               : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
      do                    : out std_logic_vector (DO_WDTH - 1 downto 0));
  end component ram_emul;

-- PC
  signal IR   : std_logic_vector (IR_BITS - 1 downto 0);
  signal IR_t : std_logic_vector (31 downto 0);
  signal SS   : std_logic;
  signal JS   : std_logic_vector (1 downto 0);
  signal EPC  : std_logic;
  signal PC   : std_logic_vector (IM_ADDR_BITS - 1 downto 0);
  --signal PC_t   : std_logic_vector (9 downto 0);

-- Instruction Decoder
  signal INT_ACK : std_logic;
  signal DR      : std_logic_vector (DR_BITS - 1 downto 0);
  signal SR      : std_logic_vector (SR_BITS - 1 downto 0);
  signal MD      : std_logic_vector (MD_BITS - 1 downto 0);
  signal fs      : std_logic_vector (FS_BITS - 1 downto 0);
  signal RW, MA, MA_sclr, SIE, LIE,
    INTP, RI, RS, WS, MB : std_logic;
  signal DM_WE        : std_logic;
  signal we, en, sclr : std_logic;

-- Stack
  signal DO : std_logic_vector (DAT_WDTH - 1 downto 0);
  signal SP : std_logic_vector (SP_WDTH - 1 downto 0);

-- Data Memory
  signal DM_AO : std_logic_vector (ADDR_WDTH - 1 downto 0);
  signal DM_DI : std_logic_vector (DI_WDTH - 1 downto 0);
  signal DM_DO : std_logic_vector (DO_WDTH - 1 downto 0);

-- Instruction Memory

-- Datapath
  signal Z, V, N, C, IE : std_logic;
  signal CI             : std_logic_vector (31 downto 0);

begin
  CI <= "00000000000" & IR(20 downto 0);  -- Datapath CI is a 32 bit sig
  --PC_t <= "000000" & PC;

  -- Datapath
  Datapath_1 : Datapath
    generic map (
      PORT_ID_BITS  => PORT_ID_BITS,
      OUT_PORT_BITS => OUT_PORT_BITS,
      IN_PORT_BITS  => IN_PORT_BITS,
      FS_BITS       => FS_BITS,
      DR_BITS       => DR_BITS,
      SR_BITS       => SR_BITS,
      MD_BITS       => MD_BITS)
    port map (
      clock        => clock,
      resetn       => resetn,
      DR           => DR,
      CI           => CI,
      DI           => DM_DO,
      MD           => MD,
      fs           => fs,
      MB           => MB,
      RW           => RW,
      MA           => MA,
      MA_sclr      => MA_sclr,
      SIE          => SIE,
      LIE          => LIE,
      INTP         => INTP,
      RI           => RI,
      RS           => RS,
      WS           => WS,
      IN_PORT      => IN_PORT,
      SR           => SR,
      Z            => Z,
      C            => C,
      V            => V,
      N            => N,
      IE           => IE,
      PORT_ID      => PORT_ID,
      READ_STROBE  => READ_STROBE,
      WRITE_STROBE => WRITE_STROBE,
      OUT_PORT     => OUT_PORT,
      AO           => DM_AO,
      DO           => DM_DI);

  -- Data memory
  ram_emul_1 : ram_emul
    generic map (
      DI_WDTH   => DI_WDTH,
      DO_WDTH   => DO_WDTH,
      ADDR_WDTH => ADDR_WDTH,
      OMUX_NOTZ => false)
    port map (
      clock   => clock,
      resetn  => resetn,
      we      => DM_WE,
      en      => '1',
      di      => DM_DI,
      address => DM_AO,
      do      => DM_DO);

  -- Instruction memory
  instr_mem_1 : instr_mem
    port map (
      clka   => clock,
      ena    => '1',
      wea(0) => '0',
      addra  => PC(9 downto 0),
      dina   => (others => '0'),
      douta  => IR,
      clkb   => clock,
      enb    => im_enb,
      web(0) => im_web,
      addrb  => im_addrb(9 downto 0),
      dinb   => im_dinb);
  --doutb => im_doutb);

  -- Stack
  stack_1 : stack
    generic map (
      SP_WDTH  => SP_WDTH,
      DAT_WDTH => DAT_WDTH)
    port map (
      we     => we,
      en     => en,
      sclr   => sclr,
      clock  => clock,
      resetn => resetn,
      DI     => PC,
      DO     => DO);

  -- Program Counter
  program_counter_1 : program_counter
    generic map (
      ADDR_WDTH => IM_ADDR_BITS)
    port map (
      clock   => clock,
      resetn  => resetn,
      ST      => DO,
      SS      => SS,
      JA_CA   => IR(15 downto 0),
      JS      => JS,
      EPC     => EPC,
      E_PC    => E_PC,
      sclr_PC => sclr_PC,
      PC      => PC);

  -- Instruction Decoder
  instruction_decoder_1 : instruction_decoder
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
      INT     => INT,
      Z       => Z,
      V       => V,
      N       => N,
      C       => C,
      IE      => IE,
      INT_ACK => INT_ACK,
      JS      => JS,
      EPC     => EPC,
      E_PC    => E_PC,
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
end structural;
