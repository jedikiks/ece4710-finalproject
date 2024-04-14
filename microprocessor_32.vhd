library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity microprocessor_32 is
  generic (
    -- Instruction Memory
    IM_DIN_BITS   : integer := 32;
    IM_ADDR_BITS  : integer := 16;
    -- Data Memory
    DI_WDTH       : integer := 32;
    DO_WDTH       : integer := 32;
    ADDR_WDTH     : integer := 6;
    -- Stack
    SP_WDTH       : integer := 5;
    DAT_WDTH      : integer := 16;
    -- Control
    IR_BITS       : integer := 32;
    -- Datapath
    FS_BITS       : integer := 5;
    DR_BITS       : integer := 5;
    SR_BITS       : integer := 5;
    MD_BITS       : integer := 2;
    -- Program Counter
    OFFSET_WDTH   : integer := 7);

  port (
    -- Input signals
    clock, resetn, INT : in  std_logic;
    -- PC signals
    E_PC, sclr_PC      : in  std_logic;
    -- Output signals
    DM_DO : out std_logic_vector (15 downto 0));
end microprocessor_32;

architecture structural of microprocessor_32 is
  component Datapath is
    generic (
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
      AO            : out std_logic_vector (5 downto 0);
      DO            : out std_logic_vector (31 downto 0));
  end component Datapath;

  component instr_mem is
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(9 downto 0);
      dina  : in  std_logic_vector(31 downto 0);
      douta : out std_logic_vector(31 downto 0));
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

  component id_fsm is
    generic (
      IR_BITS : integer;
      FS_BITS : integer;
      DR_BITS : integer;
      SR_BITS : integer;
      MD_BITS : integer);
    port (
      IR      : in  std_logic_vector (IR_BITS - 1 downto 0);
      clock   : in  std_logic;
      resetn  : in  std_logic;
      E_PC    : in  std_logic;
      INT_P   : in  std_logic;
      INT_ACK : out std_logic;
      SS      : out std_logic_vector (1 downto 0);
      JS      : out std_logic_vector (2 downto 0);
      EPC     : out std_logic;
      Z       : in  std_logic;
      V       : in  std_logic;
      N       : in  std_logic;
      C       : in  std_logic;
      DR      : out std_logic_vector (DR_BITS - 1 downto 0);
      SR      : out std_logic_vector (SR_BITS - 1 downto 0);
      MD      : out std_logic_vector (MD_BITS - 1 downto 0);
      fs      : out std_logic_vector (FS_BITS - 1 downto 0);
      RW      : out std_logic;
      MA      : out std_logic;
      MA_sclr : out std_logic;
      SIE     : out std_logic;
      LIE     : out std_logic;
      INTP    : out std_logic;
      RI      : out std_logic;
      RS      : out std_logic;
      WS      : out std_logic;
      MB      : out std_logic;
      Z_en    : out std_logic;
      V_en    : out std_logic;
      N_en    : out std_logic;
      C_en    : out std_logic;
      DM_WE   : out std_logic;
      we      : out std_logic;
      en      : out std_logic;
      sclr    : out std_logic);
  end component id_fsm;

  component program_counter is
    generic (
      ADDR_WDTH   : integer;
      OFFSET_WDTH : integer);
    port (
      clock, resetn : in  std_logic;
      ST            : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
      SS            : in  std_logic_vector (1 downto 0);
      offset        : in  std_logic_vector (OFFSET_WDTH - 1 downto 0);
      JA_CA         : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
      JS            : in  std_logic_vector (2 downto 0);
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
  signal IR     : std_logic_vector (IR_BITS - 1 downto 0);
  signal SS     : std_logic_vector (1 downto 0);
  signal JS     : std_logic_vector (2 downto 0);
  signal EPC    : std_logic;
  signal PC     : std_logic_vector (IM_ADDR_BITS - 1 downto 0);
  signal offset : std_logic_vector (OFFSET_WDTH - 1 downto 0);
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
  signal DM_DO_t : std_logic_vector (DO_WDTH - 1 downto 0);

-- Instruction Memory

-- Datapath
  signal Z, V, N, C, Z_en, V_en, N_en, C_en, IE : std_logic;
  signal CI                                     : std_logic_vector (31 downto 0);

begin
  CI     <= "00000000000" & IR(20 downto 0);  -- Datapath CI is a 32 bit sig
  --PC_t <= "000000" & PC;
  INTP   <= '0';
  offset <= IR(22 downto 16);
  DM_DO <= DM_DO_t(15 downto 0);

  -- Datapath
  Datapath_1 : Datapath
    generic map (
      FS_BITS       => FS_BITS,
      DR_BITS       => DR_BITS,
      SR_BITS       => SR_BITS,
      MD_BITS       => MD_BITS)
    port map (
      clock    => clock,
      resetn   => resetn,
      DR       => DR,
      CI       => CI,
      DI       => DM_DO_t,
      MD       => MD,
      fs       => fs,
      MB       => MB,
      RW       => RW,
      MA       => MA,
      MA_sclr  => MA_sclr,
      SIE      => SIE,
      LIE      => LIE,
      INTP     => INTP,
      RI       => RI,
      RS       => RS,
      WS       => WS,
      SR       => SR,
      Z_en     => Z_en,
      C_en     => C_en,
      V_en     => V_en,
      N_en     => N_en,
      Z        => Z,
      C        => C,
      V        => V,
      N        => N,
      IE       => IE,
      AO       => DM_AO,
      DO       => DM_DI);

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
      do      => DM_DO_t);

  -- Instruction memory
  instr_mem_1 : instr_mem
    port map (
      clka  => clock,
      wea   => "0",
      addra => PC(9 downto 0),
      dina  => (others => '0'),
      douta => IR);

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
      ADDR_WDTH   => IM_ADDR_BITS,
      OFFSET_WDTH => OFFSET_WDTH)
    port map (
      clock   => clock,
      resetn  => resetn,
      ST      => DO,
      SS      => SS,
      offset  => offset,
      JA_CA   => IR(15 downto 0),
      JS      => JS,
      EPC     => EPC,
      E_PC    => E_PC,
      sclr_PC => sclr_PC,
      PC      => PC);

  -- Instruction Decoder
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
      Z_en    => Z_en,
      C_en    => C_en,
      V_en    => V_en,
      N_en    => N_en,
      Z       => Z,
      V       => V,
      N       => N,
      C       => C,
      --IE      => IE,
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
      INT_P   => '0',
      RI      => RI,
      RS      => RS,
      WS      => WS,
      MB      => MB,
      DM_WE   => DM_WE,
      we      => we,
      en      => en,
      sclr    => sclr);
end structural;
