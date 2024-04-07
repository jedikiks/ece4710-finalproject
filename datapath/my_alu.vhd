library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_alu is
  generic (N : integer := 8);
  port (clock, resetn : in  std_logic;
        A, B          : in  std_logic_vector (N-1 downto 0);
        sel           : in  std_logic_vector (4 downto 0);
        zflag         : out std_logic;
        cflag         : out std_logic;
        vflag         : out std_logic;
        nflag         : out std_logic;
        y             : out std_logic_vector (N-1 downto 0));
end my_alu;

architecture structure of my_alu is

  component my_addsub
    generic (N : integer := 4);
    port(addsub   : in  std_logic;
         x, y     : in  std_logic_vector (N-1 downto 0);
         s        : out std_logic_vector (N-1 downto 0);
         overflow : out std_logic;
         cout     : out std_logic);
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
  component shifter is
    generic (
      N           : integer          := 8;     -- Number of bits
      SHIFT_VALUE : std_logic_vector := "001"  -- Value to be shifted in (default is '1')
      );
    port (
      idata : in  std_logic_vector(N-1 downto 0);  -- Input data
      dir   : in  std_logic;
      cin   : in  std_logic;            -- Direction (0 for left, 1 for right)
      odata : out std_logic_vector(N-1 downto 0)   -- Output data
      );
  end component;

  signal Ap1, Am1, Bp1, Bm1, ApB, AmB, AandB, AorB,
    AxorB, AandBtst, ApBpC, AmBmC : std_logic_vector (N-1 downto 0);

  signal my_one : std_logic_vector (N-1 downto 0);

  signal v0, c0, v1, c1, v2, c2, v3, c3, v4, c4, v5, c5, c6,
    c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, n0, n1, n2, n3, n4, n5,
    n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17 : std_logic;

  signal y_cout, y_overflow, coutx, overflowx, z0, z1, z2, z3, z4, z5, z6, z7, z8, z9, z10, z11,
    z12, z13, z14, z15, z16, z17, y_zero, y_negative : std_logic;

  signal slA0_out, slA1_out, slAA0_out, slAc_out, SRA0_out, sRA1_out,
    sRAA7_out, sRAc_out, rLA_out, rRA_out : std_logic_vector(7 downto 0);

  signal empty : std_logic := '0';

begin

  z0 <= not (ApB(0) or ApB(1) or ApB(2) or ApB(3) or
             ApB(4) or ApB(5) or ApB(6) or ApB(7));
  z1 <= not (ApBpC(0) or ApBpC(1) or ApBpC(2) or ApBpC(3) or
             ApBpC(4) or ApBpC(5) or ApBpC(6) or ApBpC(7));
  z2 <= not (AmB(0) or AmB(1) or AmB(2) or AmB(3) or
             AmB(4) or AmB(5) or AmB(6) or AmB(7));
  z3 <= not (AmBmC(0) or AmBmC(1) or AmBmC(2) or AmBmC(3) or
             AmBmC(4) or AmBmC(5) or AmBmC(6) or AmBmC(7));
  z4 <= not (AandB(0) or AandB(1) or AandB(2) or AandB(3) or
             AandB(4) or AandB(5) or AandB(6) or AandB(7));
  z5 <= not (AandBtst(0) or AandBtst(1) or AandBtst(2) or AandBtst(3) or
             AandBtst(4) or AandBtst(5) or AandBtst(6) or AandBtst(7));
  z6 <= not (AorB(0) or AorB(1) or AorB(2) or AorB(3) or
             AorB(4) or AorB(5) or AorB(6) or AorB(7));
  z7 <= not (AxorB(0) or AxorB(1) or AxorB(2) or AxorB(3) or
             AxorB(4) or AxorB(5) or AxorB(6) or AxorB(7));
  z8 <= not (slA0_out(0) or slA0_out(1) or slA0_out(2) or slA0_out(3) or
             slA0_out(4) or slA0_out(5) or slA0_out(6) or slA0_out(7));
  z9 <= not (slA1_out(0) or slA1_out(1) or slA1_out(2) or slA1_out(3) or
             slA1_out(4) or slA1_out(5) or slA1_out(6) or slA1_out(7));
  z10 <= not (slAA0_out(0) or slAA0_out(1) or slAA0_out(2) or slAA0_out(3) or
              slAA0_out(4) or slAA0_out(5) or slAA0_out(6) or slAA0_out(7));
  z11 <= not (slAc_out(0) or slAc_out(1) or slAc_out(2) or slAc_out(3) or
              slAc_out(4) or slAc_out(5) or slAc_out(6) or slAc_out(7));
  z12 <= not (sRA0_out(0) or sRA0_out(1) or sRA0_out(2) or sRA0_out(3) or
              sRA0_out(4) or sRA0_out(5) or sRA0_out(6) or sRA0_out(7));
  z13 <= not (sRA1_out(0) or sRA1_out(1) or sRA1_out(2) or sRA1_out(3) or
              sRA1_out(4) or sRA1_out(5) or sRA1_out(6) or sRA1_out(7));
  z14 <= not (sRAA7_out(0) or sRAA7_out(1) or sRAA7_out(2) or sRAA7_out(3) or
              sRAA7_out(4) or sRAA7_out(5) or sRAA7_out(6) or sRAA7_out(7));
  z15 <= not (sRAc_out(0) or sRAc_out(1) or sRAc_out(2) or sRAc_out(3) or
              sRAc_out(4) or sRAc_out(5) or sRAc_out(6) or sRAc_out(7));
  z16 <= not (rLA_out(0) or rLA_out(1) or rLA_out(2) or rLA_out(3) or
              rLA_out(4) or rLA_out(5) or rLA_out(6) or rLA_out(7));
  z17 <= not (rRA_out(0) or rRA_out(1) or rRA_out(2) or rRA_out(3) or
              rRA_out(4) or rRA_out(5) or rRA_out(6) or rRA_out(7));

  n0  <= ApB(7) and '1';
  n1  <= ApBpC(7) and '1';
  n2  <= AmB(7) and '1';
  n3  <= AmBmC(7) and '1';
  n4  <= AandB(7) and '1';
  n5  <= AandBtst(7) and '1';
  n6  <= AorB(7) and '1';
  n7  <= AxorB(7) and '1';
  n8  <= slA0_out(7) and '1';
  n9  <= slA1_out(7) and '1';
  n10 <= slAA0_out(7) and '1';
  n11 <= slAc_out(7) and '1';
  n12 <= sRA0_out(7) and '1';
  n13 <= sRA1_out(7) and '1';
  n14 <= sRAA7_out(7) and '1';
  n15 <= sRAc_out(7) and '1';
  n16 <= rLA_out(7) and '1';
  n17 <= rRA_out(7) and '1';

-- A + B                      
  f0 : my_addsub generic map (N => N)
    port map (addsub => '0', x => A, y => B, s => ApB, cout => c0, overflow => v0);
-- A + B + c 
  f1 : my_addsub generic map (N => N)
    port map(addsub => '0', x => ApB, y => x"01", s => ApBpC, cout => c1, overflow => v1);
-- A - B
  f2 : my_addsub generic map (N => N)
    port map (addsub => '1', x => A, y => B, s => AmB, cout => c2, overflow => v2);
-- A - B - c
  f3 : my_addsub generic map (N => N)
    port map (addsub => '1', x => AmB, y => x"01", s => AmBmC, cout => c3, overflow => v3);

  f4 : AandB <= A and B;

  f5 : AandBtst <= A and B;

  f6 : AorB <= A or B;

  f7 : AxorB <= A xor B;

-- left-shift A, din = 0
  f8 : shifter generic map(N => 8, SHIFT_VALUE => "000")
    port map(idata => A, dir => '0', cin => '0', odata => slA0_out);

  f9 : shifter generic map(N => 8, SHIFT_VALUE => "001")
    port map(idata => A, dir => '0', cin => '0', odata => slA1_out);

  f10 : shifter generic map(N => 8, SHIFT_VALUE => "010")
    port map(idata => A, dir => '0', cin => '0', odata => slAA0_out);

  f11 : shifter generic map(N => 8, SHIFT_VALUE => "011")
    port map(idata => A, dir => '0', cin => y_cout, odata => slAc_out);

  f12 : shifter generic map(N => 8, SHIFT_VALUE => "000")
    port map(idata => A, dir => '1', cin => '0', odata => sRA0_out);

  f13 : shifter generic map(N => 8, SHIFT_VALUE => "001")
    port map(idata => A, dir => '1', cin => '0', odata => sRA1_out);

  f14 : shifter generic map(N => 8, SHIFT_VALUE => "010")
    port map(idata => A, dir => '1', cin => '0', odata => sRAA7_out);

  f15 : shifter generic map(N => 8, SHIFT_VALUE => "011")
    port map(idata => A, dir => '1', cin => y_cout, odata => sRAc_out);

  f16 : shifter generic map(N => 8, SHIFT_VALUE => "100")
    port map(idata => A, dir => '0', cin => '0', odata => rLA_out);

  f17 : shifter generic map(N => 8, SHIFT_VALUE => "100")
    port map(idata => A, dir => '1', cin => '0', odata => rRA_out);

  c4 <= '0';
  c5 <= AandBtst(7) xor AandBtst(6) xor AandBtst(5) xor AandBtst(4) xor AandBtst(3) xor
        AandBtst(2) xor AandBtst(1) xor AandBtst(0);
  c6  <= '0';
  c7  <= '0';
  c8  <= A(7);
  c9  <= A(7);
  c10 <= A(7);
  c11 <= A(7);
  c12 <= A(0);
  c13 <= A(0);
  c14 <= A(0);
  c15 <= A(7);
  c16 <= A(7);
  c17 <= A(0);

  fcout : FlipFlop port map (d => y_cout, clrn => '1', prn => '1', clk => clock, ena => '1', sclr => '0', q => cflag);

  foverflow : FlipFlop port map (d => y_overflow, clrn => '1', prn => '1', clk => clock, ena => '1', sclr => '0',
                                 q => vflag);

  fzero : FlipFlop port map (d => y_zero, clrn => '1', prn => '1', clk => clock, ena => '1', sclr => '0', q => zflag);

  fnegative : FlipFlop port map (d => y_negative, clrn => '1', prn => '1', clk => clock, ena => '1', sclr => '0',
                                 q => nflag);

-- Multiplexor
  with sel select
    y <= A          when "00000",
    ApB             when "00001",
    ApBpC           when "00010",
    AmB             when "00100",
    AmBmC           when "00101",
    AandB           when "01000",
    AandBtst        when "10111",
    AorB            when "01001",
    AxorB           when "01010",
    sLA0_out        when "01101",
    sLA1_out        when "01110",
    sLAA0_out       when "01111",
    sLAc_out        when "10000",
    SRA0_out        when "10001",
    SRA1_out        when "10010",
    SRAA7_out       when "10011",
    SRAc_out        when "10100",
    rLA_out         when "10101",
    rRA_out         when "10110",
    (others => '0') when others;



  with sel select
    y_cout <= empty when "00000",
    c0              when "00001",
    c1              when "00010",
    c2              when "00100",
    c3              when "00101",
    c4              when "01000",
    c5              when "10111",
    c6              when "01001",
    c7              when "01010",
    c8              when "01101",
    c9              when "01110",
    c10             when "01111",
    c11             when "10000",
    c12             when "10001",
    c13             when "10010",
    c14             when "10011",
    c15             when "10100",
    c16             when "10101",
    c17             when "10110",
    empty           when others;


  with sel select
    y_overflow <= empty when "00000",
    v0                  when "00001",
    v1                  when "00010",
    v2                  when "00100",
    v3                  when "00101",
    empty               when "01000",
    empty               when "10111",
    empty               when "01001",
    empty               when "01010",
    empty               when "01101",
    empty               when "01110",
    empty               when "01111",
    empty               when "10000",
    empty               when "10001",
    empty               when "10010",
    empty               when "10011",
    empty               when "10100",
    empty               when "10101",
    empty               when "10110",
    empty               when others;


  with sel select
    y_zero <= empty when "00000",
    z0              when "00001",
    z1              when "00010",
    z2              when "00100",
    z3              when "00101",
    z4              when "01000",
    z5              when "10111",
    z6              when "01001",
    z7              when "01010",
    z8              when "01101",
    z9              when "01110",
    z10             when "01111",
    z11             when "10000",
    z12             when "10001",
    z13             when "10010",
    z14             when "10011",
    z15             when "10100",
    z16             when "10101",
    z17             when "10110",
    empty           when others;

  with sel select
    y_negative <= empty when "00000",
    n0                  when "00001",
    n1                  when "00010",
    n2                  when "00100",
    n3                  when "00101",
    n4                  when "01000",
    n5                  when "10111",
    n6                  when "01001",
    n7                  when "01010",
    n8                  when "01101",
    n9                  when "01110",
    n10                 when "01111",
    n11                 when "10000",
    n12                 when "10001",
    n13                 when "10010",
    n14                 when "10011",
    n15                 when "10100",
    n16                 when "10101",
    n17                 when "10110",
    empty               when others;
end structure;
