library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec is
  generic (
    NI : integer := 4;
    NO : integer := 2
    );
  port(
    input  : in  std_logic_vector (NI - 1 downto 0);
    output : out std_logic_vector (NO - 1 downto 0)
    );
end dec;

architecture behavioral of dec is
begin
  process (input)
  begin
    output                              <= (others => '0');
    output(to_integer(unsigned(input))) <= '1';
  end process;
end behavioral;
