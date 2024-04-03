library ieee;
use ieee.std_logic_1164.all;

entity tb_top is
  generic (
    -- Instruction Memory
    IM_ADDR_BITS  : integer := 11;
    IM_DATA_BITS  : integer := 18;
    -- Data Memory
    DI_WDTH       : integer := 8;
    DO_WDTH       : integer := 8;
    ADDR_WDTH     : integer := 6;
    -- Stack
    SP_WDTH       : integer := 5;
    DAT_WDTH      : integer := 10;
    -- Control
    IR_BITS       : integer := 18;
    -- Datapath
    FS_BITS       : integer := 5;
    DR_BITS       : integer := 4;
    SR_BITS       : integer := 4;
    MD_BITS       : integer := 2;
    PORT_ID_BITS  : integer := 8;
    OUT_PORT_BITS : integer := 8;
    IN_PORT_BITS  : integer := 8);
end tb_top;

architecture behavior of tb_top is

  -- Component Declaration for the Unit Under Test (UUT)
  component top is
    generic (
      -- Instruction Memory
      IM_ADDR_BITS  : integer;
      IM_DATA_BITS  : integer;
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
    port (clock, resetn, INT,
          E_PC, sclr_PC, IM_WE      : in  std_logic;
          IM_DI                     : in  std_logic_vector (IM_DATA_BITS - 1 downto 0);
          IN_PORT                   : in  std_logic_vector (IN_PORT_BITS - 1 downto 0);
          READ_STROBE, WRITE_STROBE : out std_logic;
          PORT_ID                   : out std_logic_vector (PORT_ID_BITS - 1 downto 0);
          OUT_PORT                  : out std_logic_vector (OUT_PORT_BITS - 1 downto 0));
  end component top;

  --Inputs
  signal clock        : std_logic                                     := '0';
  signal resetn       : std_logic                                     := '0';
  signal INT          : std_logic                                     := '0';
  signal E_PC         : std_logic                                     := '0';
  signal sclr_PC      : std_logic                                     := '0';
  signal IM_WE        : std_logic                                     := '0';
  signal READ_STROBE  : std_logic                                     := '0';
  signal WRITE_STROBE : std_logic                                     := '0';
  signal IM_DI        : std_logic_vector (IM_DATA_BITS - 1 downto 0)  := (others => '0');
  signal PORT_ID      : std_logic_vector (PORT_ID_BITS - 1 downto 0)  := (others => '0');
  signal OUT_PORT     : std_logic_vector (OUT_PORT_BITS - 1 downto 0) := (others => '0');
  signal IN_PORT      : std_logic_vector (IN_PORT_BITS - 1 downto 0)  := (others => '0');
  --Outputs

  -- Clock period definitions
  constant clock_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  top_1 : top
    generic map (
      IM_ADDR_BITS  => IM_ADDR_BITS,
      IM_DATA_BITS  => IM_DATA_BITS,
      DI_WDTH       => DI_WDTH,
      DO_WDTH       => DO_WDTH,
      ADDR_WDTH     => ADDR_WDTH,
      SP_WDTH       => SP_WDTH,
      DAT_WDTH      => DAT_WDTH,
      IR_BITS       => IR_BITS,
      FS_BITS       => FS_BITS,
      DR_BITS       => DR_BITS,
      SR_BITS       => SR_BITS,
      MD_BITS       => MD_BITS,
      PORT_ID_BITS  => PORT_ID_BITS,
      OUT_PORT_BITS => OUT_PORT_BITS,
      IN_PORT_BITS  => IN_PORT_BITS)
    port map (
      clock        => clock,
      resetn       => resetn,
      INT          => INT,
      E_PC         => E_PC,
      sclr_PC      => sclr_PC,
      IM_WE        => IM_WE,
      IM_DI        => IM_DI,
      READ_STROBE  => READ_STROBE,
      WRITE_STROBE => WRITE_STROBE,
      PORT_ID      => PORT_ID,
      OUT_PORT     => OUT_PORT,
      IN_PORT      => IN_PORT);

  -- Clock process definitions
  clock_process : process
  begin
    clock <= '0';
    wait for clock_period/2;
    clock <= '1';
    wait for clock_period/2;
  end process;

  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;
    wait for clock_period;
    resetn <= '1';

    E_PC <= '1';

    --=======================
    -- insert stimulus here
    --=======================
    -- Intial load stage
    IR <= "000001" & "0010" & "0011" & "0000";  -- LOAD s2, s3
    wait for 2 * clock_period;

    IR <= "011001" & "0110" & "0010" & "0000";  -- ADD s6, s2
    wait for 2 * clock_period;

    IR <= (others => '-');
    wait;
  --assert false report "Finish" severity failure;
  end process;
end;
