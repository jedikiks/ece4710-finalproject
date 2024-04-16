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
  port (clock, resetn, rdy : in  std_logic;
        addr_sel           : in  std_logic_vector (1 downto 0);
        TXD                : out std_logic);
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
      clock, resetn : in  std_logic;
      DM_AO_B       : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
      E_PC, sclr_PC : in  std_logic;
      DM_DO_B       : out std_logic_vector (DO_WDTH - 1 downto 0));
  end component microprocessor_32;

  component uart_output is
    port (
      resetn, clock : in  std_logic;
      rdy           : in  std_logic;
      din           : in  std_logic_vector (31 downto 0);
      TXD           : out std_logic);
  end component uart_output;

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

  signal clk_50mhz, E_PC : std_logic;
  signal DM_DO_B         : std_logic_vector(31 downto 0);
  signal DM_AO_B         : std_logic_vector(5 downto 0);

begin

  with addr_sel select
    DM_AO_B <= "111111" when "00",
    "111110"            when "01",
    "111101"            when "10",
    "111100"            when others;

  MMCM_wrapper_1 : MMCM_wrapper
    generic map (
      O_0 => O_0,
      O_1 => O_1,
      O_2 => O_2)
    port map (
      clock   => clock,
      resetn  => resetn,
      clkout0 => clk_50mhz);

  uart_output_1 : uart_output
    port map (
      resetn => resetn,
      clock  => clock,
      rdy    => rdy,
      din    => DM_DO_B,
      TXD    => TXD);

  microprocessor_32_2 : microprocessor_32
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
      DM_AO_B => DM_AO_B,
      E_PC    => '1',
      sclr_PC => '0',
      DM_DO_B => DM_DO_B);

end structural;
