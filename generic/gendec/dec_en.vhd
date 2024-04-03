library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec_en is
  generic (
    NI : integer := 4;
    NO : integer := 2);

  port (
    input  : in  std_logic_vector(NI - 1 downto 0);
    e      : in  std_logic;
    output : out std_logic_vector (NO - 1 downto 0));
end dec_en;

architecture behavioral of dec_en is
begin
  process(input, e)
  begin
    output <= (others => '0');
    if e = '1' then
      output(to_integer(unsigned(input))) <= '1';
    else
      output <= (others => '0');
    end if;
  end process;
end;
