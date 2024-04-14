---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2021).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

library UNISIM;
use UNISIM.vcomponents.all;

-- This only works for Artix-7 or 7-series PL
-- Primitive used: MMCME2_BASE
-- *********************** 
-- Basic Frequency Synthesizer. This works for input frequency of 100 MHz for Artix-7 FPGAs

-- F(VCO) = FCLKIN*M/D (internal VCO, CLKIN = CLKIN1)

-- CLKOUT{#} = F(VCO)/O{#} = CLKIN*(M/D)/O
--    * With M=D --> FVCO = FCLKIN, => FOUT{#} = FCLKIN/O{#}
-- CLKFBOUT = CLKIN*(M/D)/M = CLKIN/D

entity MMCM_wrapper is
  generic (constant O_0 : integer := 1;
           constant O_1 : integer := 2;
           constant O_2 : integer := 4);
  port (clock                     : in  std_logic;
        resetn                    : in  std_logic;
        clkout0, clkout1, clkout2 : out std_logic;
        locked                    : out std_logic);  -- MMCM must be reset after 'locked' is deasserted
end MMCM_wrapper;

architecture structure of MMCM_wrapper is
  signal CLKIN1              : std_logic;
  signal CLKFBIN             : std_logic;  -- must be connected to CLKFBOUT for internal feedback
  signal RST                 : std_logic;  -- asynchronous reset. Required when input clock conditions change (frequency, phase)
  signal PWRDWN              : std_logic;
  signal CLKFBOUT, CLKFBOUTB : std_logic;

  --signal CLKOUT0, CLKOUT1, CLKOUT2: std_logic
  signal CLKOUT3, CLKOUT4, CLKOUT5, CLKOUT6     : std_logic;
  signal CLKOUT0B, CLKOUT1B, CLKOUT2B, CLKOUT3B : std_logic;  -- inverted clock outputs

-- **************************************************************************************
-- F_VCO = FCLKIN*M/D (internal VCO, CLKIN = CLKIN1)
--   * Restriction (Artix 7): 600 MHz <= F_VCO <= 1200 (or 1440, 1600 in some devices)
-- ==> If input clock is 100 MHZ --> we choose M = 8, D = 1 --> F_VCO = 800 MHz
-- CLKFBOUT = CLKIN*(M/D)/M = CLKIN/D ==> with M=8,D=1 --> CLKFBOUT = CLKIN

-- CLKOUT{#} = F_VCO/O{#} = CLKIN*(M/D)/O{#}.
--  * With M=8, D=1 --> CLKOUT{#} = CLKIN*8/O{#}
--    If we want to divide by 2, we need O{#} = 16 (2*M)
--    If we want to divide by 4, we need o(#) = 32 (4*M)
-- **************************************************************************************** 

  constant T_CLKIN : real    := 10.0;   -- ns
  constant M       : real    := 8.0;    -- 2.0 -> 64.0
  constant D       : integer := 1;      -- 1 --> 106

  constant O0 : real    := real(O_0)*M;     -- 1.0 --> 128.0
  constant O1 : integer := O_1*integer(M);  -- 1--> 128
  constant O2 : integer := O_2*integer(M);

begin

-- MMCME2_BASE Ports
-- -----------------
-- Clock input: CLKIN1, CLFKFBIN
-- Control inputs: RST
-- Clock Outputs: CLKOUT0 - CLKTOUT6, CLKOUT0B - CLKOUT3B, CLKFBOUT, CLKFBOUTB
-- Status and Data Outputs: LOCKED
-- Power Control: PWRDWN

-- Parameters:
--  M: CLKFBOUT_MULT_F (fractional). 2 to 64
--  D: DIVCLK_DIVIDE
--  O{#}: CLKOUT{#}_DIVIDE (integer)
--  O0: CLKOUT0_DIVIDE_F (allows for fractional divide)

  CLKIN1  <= clock;  -- double check if a BUFG is needed in-between
  CLKFBIN <= CLKFBOUT;
  RST     <= not (resetn);
  PWRDWN  <= '0';

  MMCME2_BASE_inst : MMCME2_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F    => M,  --5.0,    -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE     => 0.0,  -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD      => T_CLKIN,  -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE     => O1,
      CLKOUT2_DIVIDE     => O2,
      CLKOUT3_DIVIDE     => 1,
      CLKOUT4_DIVIDE     => 1,
      CLKOUT5_DIVIDE     => 1,
      CLKOUT6_DIVIDE     => 1,
      CLKOUT0_DIVIDE_F   => O0,   -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE      => 0.0,
      CLKOUT1_PHASE      => 0.0,
      CLKOUT2_PHASE      => 0.0,
      CLKOUT3_PHASE      => 0.0,
      CLKOUT4_PHASE      => 0.0,
      CLKOUT5_PHASE      => 0.0,
      CLKOUT6_PHASE      => 0.0,
      CLKOUT4_CASCADE    => false,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      DIVCLK_DIVIDE      => D,          -- Master division value (1-106)
      REF_JITTER1        => 0.0,  -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT       => false  -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
    port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0   => CLKOUT0,             -- 1-bit output: CLKOUT0
      CLKOUT0B  => CLKOUT0B,            -- 1-bit output: Inverted CLKOUT0
      CLKOUT1   => CLKOUT1,             -- 1-bit output: CLKOUT1
      CLKOUT1B  => CLKOUT1B,            -- 1-bit output: Inverted CLKOUT1
      CLKOUT2   => CLKOUT2,             -- 1-bit output: CLKOUT2
      CLKOUT2B  => CLKOUT2B,            -- 1-bit output: Inverted CLKOUT2
      CLKOUT3   => CLKOUT3,             -- 1-bit output: CLKOUT3
      CLKOUT3B  => CLKOUT3B,            -- 1-bit output: Inverted CLKOUT3
      CLKOUT4   => CLKOUT4,             -- 1-bit output: CLKOUT4
      CLKOUT5   => CLKOUT5,             -- 1-bit output: CLKOUT5
      CLKOUT6   => CLKOUT6,             -- 1-bit output: CLKOUT6
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT  => CLKFBOUT,            -- 1-bit output: Feedback clock
      CLKFBOUTB => CLKFBOUTB,           -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED    => LOCKED,              -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1    => CLKIN1,              -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN    => PWRDWN,              -- 1-bit input: Power-down
      RST       => RST,                 -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN   => CLKFBIN              -- 1-bit input: Feedback clock
      );
  -- End of MMCME2_BASE_inst instantiation

end structure;
