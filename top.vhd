library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top is
  generic (
    -- MMCM
    O_0          : integer := 3;
    O_1          : integer := 2;
    O_2          : integer := 4;
    -- Instruction Memory
    IM_DIN_BITS  : integer := 32;
    IM_ADDR_BITS : integer := 16;
    -- Data Memory
    DI_WDTH      : integer := 32;
    DO_WDTH      : integer := 32;
    ADDR_WDTH    : integer := 6;
    -- Stack
    SP_WDTH      : integer := 5;
    DAT_WDTH     : integer := 16;
    -- Control
    IR_BITS      : integer := 32;
    -- Datapath
    FS_BITS      : integer := 5;
    DR_BITS      : integer := 5;
    SR_BITS      : integer := 5;
    MD_BITS      : integer := 2;
    -- Program Counter
    OFFSET_WDTH  : integer := 7);
  port (
    clock, resetn : in  std_logic;
    E_PC, sclr_PC : in  std_logic;
    DM_DO         : out std_logic_vector (15 downto 0));
end top;

architecture structural of top is
  component microprocessor_32 is
    generic (
      IM_DIN_BITS  : integer;
      IM_ADDR_BITS : integer;
      DI_WDTH      : integer;
      DO_WDTH      : integer;
      ADDR_WDTH    : integer;
      SP_WDTH      : integer;
      DAT_WDTH     : integer;
      IR_BITS      : integer;
      FS_BITS      : integer;
      DR_BITS      : integer;
      SR_BITS      : integer;
      MD_BITS      : integer;
      OFFSET_WDTH  : integer);
    port (
      clock   : in  std_logic;
      resetn  : in  std_logic;
      E_PC    : in  std_logic;
      sclr_PC : in  std_logic;
      DM_DO   : out std_logic_vector (15 downto 0));
  end component microprocessor_32;

  component mydebouncer is
    port (
      resetn, clock : in  std_logic;
      w             : in  std_logic;
      w_db          : out std_logic);
  end component mydebouncer;

  component mypulse_det is
    port (
      clock, resetn : in  std_logic;
      x             : in  std_logic;
      z             : out std_logic);
  end component mypulse_det;

  component MMCM_wrapper is
    generic (
      constant O_0 : integer;
      constant O_1 : integer;
      constant O_2 : integer);
    port (
      clock                     : in  std_logic;
      resetn                    : in  std_logic;
      clkout0, clkout1, clkout2 : out std_logic;
      locked                    : out std_logic);
  end component MMCM_wrapper;

  signal debouncer_out_E_PC, pulse_det_out, clk_50mhz : std_logic;

begin
  MMCM_wrapper_1 : MMCM_wrapper
    generic map (
      O_0 => O_0,
      O_1 => O_1,
      O_2 => O_2)
    port map (
      clock   => clock,
      resetn  => resetn,
      clkout0 => clk_50mhz);

  mypulse_det_1 : mypulse_det
    port map (
      clock  => clk_50mhz,
      resetn => resetn,
      x      => debouncer_out_E_PC,
      z      => pulse_det_out);

  mydebouncer_E_PC : mydebouncer
    port map (
      resetn => resetn,
      clock  => clk_50mhz,
      w      => E_PC,
      w_db   => debouncer_out_E_PC);

  microprocessor_32_1 : microprocessor_32
    generic map (
      IM_DIN_BITS  => IM_DIN_BITS,
      IM_ADDR_BITS => IM_ADDR_BITS,
      DI_WDTH      => DI_WDTH,
      DO_WDTH      => DO_WDTH,
      ADDR_WDTH    => ADDR_WDTH,
      SP_WDTH      => SP_WDTH,
      DAT_WDTH     => DAT_WDTH,
      IR_BITS      => IR_BITS,
      FS_BITS      => FS_BITS,
      DR_BITS      => DR_BITS,
      SR_BITS      => SR_BITS,
      MD_BITS      => MD_BITS,
      OFFSET_WDTH  => OFFSET_WDTH)
    port map (
      clock   => clk_50mhz,
      resetn  => resetn,
      E_PC    => '1',
      sclr_PC => '0',
      DM_DO   => DM_DO);

end structural;
