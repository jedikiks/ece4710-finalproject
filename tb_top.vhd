library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top is
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
end tb_top;

architecture behavior of tb_top is

  -- Component Declaration for the Unit Under Test (UUT)
  component top is
    generic (
      IM_DIN_BITS   : integer;
      IM_ADDR_BITS  : integer;
      DI_WDTH       : integer;
      DO_WDTH       : integer;
      ADDR_WDTH     : integer;
      SP_WDTH       : integer;
      DAT_WDTH      : integer;
      IR_BITS       : integer;
      FS_BITS       : integer;
      DR_BITS       : integer;
      SR_BITS       : integer;
      MD_BITS       : integer;
      OFFSET_WDTH   : integer);
    port (
      clock, resetn, INT : in  std_logic;
      E_PC, sclr_PC      : in  std_logic;
      DM_DO : out std_logic_vector (15 downto 0));
  end component top;

  --Inputs
  signal clock    : std_logic                                    := '0';
  signal resetn   : std_logic                                    := '0';
  signal INT      : std_logic                                    := '0';
  signal E_PC     : std_logic                                    := '1';
  signal sclr_PC  : std_logic                                    := '0';
  --Outputs
  signal DM_DO :  std_logic_vector (15 downto 0);

  -- Clock period definitions
  constant clock_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  top_1 : top
    generic map (
      IM_DIN_BITS   => IM_DIN_BITS,
      IM_ADDR_BITS  => IM_ADDR_BITS,
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
      OFFSET_WDTH   => OFFSET_WDTH)
    port map (
      clock    => clock,
      resetn   => resetn,
      INT      => INT,
      E_PC     => E_PC,
      sclr_PC  => sclr_PC,
      DM_DO => DM_DO);

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
    resetn <= '1';

    --======================================================================
    -- Insert stimulus here
    --======================================================================
    --======================
    -- Load instructions
    --======================
    --im_web <= '1';
    --im_enb <= '1';

    --At address 0:
   -- im_dinb <= "000000" & "00000" & "000000000000000000010";  -- LOAD s0, #2
   -- wait for clock_period;

   -- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
   -- im_dinb <= "000000" & "00001" & "000000000000000000010";  -- LOAD s1, #2
   -- wait for clock_period;

   -- -- s16's a counter w/ value 4
   -- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
   -- im_dinb <= "000000" & "10000" & "000000000000000000100";  -- LOAD s16, #4
   -- wait for clock_period;

   -- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
   -- im_dinb  <= "011001" & "00000" & "00001" & x"0000";  -- ADD s0, s1
   -- wait for clock_period;

   -- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
   -- im_dinb  <= "101111" & "00000" & "00011" & x"0000";  -- STORE s0, s3
   -- wait for clock_period;

   -- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
   -- im_dinb  <= "011100" & "10000" & "000000000000000000001";  -- SUBI s16, #1
   -- wait for clock_period;

   -- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
   -- im_dinb  <= "110011" & "001" & "1111110" & x"0000";  -- BR NZ, -2
   -- wait for clock_period;

   -- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
   -- im_dinb <= "000000" & "00100" & "000000000000000000010";  -- LOAD s4, #2
   -- wait for clock_period;

   -- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
   -- im_dinb  <= "110000" & x"100";      -- CALL $100
   -- wait for clock_period;

   -- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
   -- im_dinb  <= "101010" & "0000" & "0000" & "0000";  -- RETURN
   -- wait for clock_period;


    --======================
    -- Finish loading
    --======================
   -- im_enb <= '0';
   -- im_web <= '0';
   -- E_PC   <= '1';

    wait;
  end process;
end;

--================================
-- Tested instructions
--================================
--==================
-- PASS
--==================
--  im_dinb <= "000000" & "0000" & "00000010";  -- LOAD s0, #2
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "101110" & "0000" & x"FF";  -- STORE s0, $FF
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "000110" & "1000" & x"FF";  -- FETCH s8, $FF
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "000000" & "0001" & "00000010";  -- LOAD s1, #2
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "011001" & "0000" & "0001" & "0000";  -- ADD s0, s1
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "000000" & "0001" & "00000011";  -- LOAD s1, #3
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "101111" & "0000" & "0001" & "0000";  -- STORE s0, (s1) ; should
--                                                   -- be 4 at addr 3
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "000111" & "0101" & "0001" & "0000";  -- FETCH s5, (s1) ; s5 should be
--                                                   -- 4
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "101010" & "0000" & "0000" & "0000";  -- RETURN
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "110000" & x"100";  -- CALL $100
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "100000" & "0000" & "00000010";  -- SL0 s0
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "100000" & "0000" & "00000110";  -- SR0 s0
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "100000" & "0000" & "00000000";  -- RL s0
--  wait for clock_period;

--  im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
--  im_dinb <= "100000" & "0000" & "00000001";  -- RR s0
--  wait for clock_period;

-- 32 bit versions:
-- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
-- im_dinb  <= "000000" & "00001" & "000000000000000000010";  -- LOAD s0, #2
-- wait for clock_period;

-- im_addrb <= std_logic_vector(to_unsigned(to_integer(unsigned(im_addrb)) + 1, im_addrb'length));
-- im_dinb  <= "011001" & "00000" & "00001" & x"0000";  -- ADD s0, s1
-- wait for clock_period;
--==================
-- FAIL
--==================
