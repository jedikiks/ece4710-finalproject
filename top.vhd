library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top_p2 is
  generic (
    -- MMCM
    O_0         : integer := 2;
    O_1         : integer := 2;
    O_2         : integer := 4;
    -- instload_ctrl
    ADDR_WDTH   : integer := 6;
    WORD_WDTH   : integer := 16;
    -- Program counter
    OFFSET_WDTH : integer := 6);
  port (
    clock, resetn     : in  std_logic;
    -- instload_ctrl
    start, step, L_in : in  std_logic;
    -- Data memory
    DM_DO             : out std_logic_vector (15 downto 0));
end top_p2;

architecture structural of top_p2 is
  component top is
    generic (
      ADDR_WDTH   : integer;
      WORD_WDTH   : integer;
      OFFSET_WDTH : integer);
    port (
      clock, resetn                  : in  std_logic;
      start, step, L_in, L_ex, we_ex : in  std_logic;
      D_ex                           : in  std_logic_vector (15 downto 0);
      DM_DO                          : out std_logic_vector (15 downto 0));
  end component top;

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

  signal debouncer_out_L_in, debouncer_out_start,
    debouncer_out_step, pulse_det_out, clk_50mhz : std_logic;

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
      x      => debouncer_out_step,
      z      => pulse_det_out);

  mydebouncer_L_in : mydebouncer
    port map (
      resetn => resetn,
      clock  => clk_50mhz,
      w      => L_in,
      w_db   => debouncer_out_L_in);

  mydebouncer_start : mydebouncer
    port map (
      resetn => resetn,
      clock  => clk_50mhz,
      w      => start,
      w_db   => debouncer_out_start);

  mydebouncer_step : mydebouncer
    port map (
      resetn => resetn,
      clock  => clk_50mhz,
      w      => step,
      w_db   => debouncer_out_step);

  top_1 : top
    generic map (
      ADDR_WDTH   => ADDR_WDTH,
      WORD_WDTH   => WORD_WDTH,
      OFFSET_WDTH => OFFSET_WDTH)
    port map (
      clock  => clk_50mhz,
      resetn => resetn,
      start  => debouncer_out_start,
      step   => pulse_det_out,
      L_in   => debouncer_out_L_in,
      L_ex   => '0',
      we_ex  => '0',
      D_ex   => (others => '0'),
      DM_DO  => DM_DO);

end structural;
