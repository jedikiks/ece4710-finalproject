library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_decoder is
  generic (NI : integer := 4;
           NO : integer := 2;
           EN : boolean := true);
  port (input  : in  std_logic_vector (NI - 1 downto 0);
        e      : in  std_logic;
        output : out std_logic_vector (NO - 1 downto 0));
end gen_decoder;

architecture behavioral of gen_decoder is
  component dec_en
    generic (
      NI : integer := 4;
      NO : integer := 2);
    port (
      input  : in  std_logic_vector(NI - 1 downto 0);
      e      : in  std_logic;
      output : out std_logic_vector (NO - 1 downto 0));
  end component;

  component dec
    generic (
      NI : integer := 4;
      NO : integer := 2);
    port (
      input  : in  std_logic_vector(NI - 1 downto 0);
      output : out std_logic_vector (NO - 1 downto 0));
  end component;

begin
  dwe : if EN = true generate
    dce : dec_en generic map (NI => NI, NO => NO)
      port map (input => input, e => e, output => output);
  end generate;

  dwoe : if EN = false generate
    dc : dec generic map (NI => NI, NO => NO)
      port map (input => input, output => output);
  end generate;
end;
