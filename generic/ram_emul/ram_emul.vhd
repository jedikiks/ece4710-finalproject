library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity ram_emul is
  generic (DI_WDTH   : integer := 4;
           DO_WDTH   : integer := 4;
           ADDR_WDTH : integer := 3;
           OMUX_NOTZ : boolean := true);
  port (clock, resetn, we, en : in  std_logic;
        di                    : in  std_logic_vector (DI_WDTH - 1 downto 0);
        address               : in  std_logic_vector (ADDR_WDTH - 1 downto 0);
        do                    : out std_logic_vector (DO_WDTH - 1 downto 0));
end ram_emul;

architecture structural of ram_emul is

  component gen_decoder
    generic (NI : integer := 4;
             NO : integer := 2;
             EN : boolean := true);
    port (input  : in  std_logic_vector (NI - 1 downto 0);
          e      : in  std_logic;
          output : out std_logic_vector (NO - 1 downto 0));
  end component;

  component my_rege
    generic (N : integer := 4);
    port (clock, resetn : in  std_logic;
          E, sclr       : in  std_logic;  -- sclr: Synchronous clear
          D             : in  std_logic_vector (N-1 downto 0);
          Q             : out std_logic_vector (N-1 downto 0));
  end component;

  type arr_2d_t is array ((2 ** ADDR_WDTH) - 1 downto 0) of std_logic_vector (DI_WDTH - 1 downto 0);
  signal regs_inpt, regs_oupt : arr_2d_t;

  signal z       : std_logic;
  signal regs_en : std_logic_vector (2 ** ADDR_WDTH - 1 downto 0);

begin

  z <= we and en;

  -- Generate array for register inputs
  process (di)
  begin
    for i in 0 to (2 ** ADDR_WDTH) - 1 loop
      regs_inpt(i) <= di;
    end loop;
  end process;

  -- Output multiplexor
  process (regs_oupt, z, address)
  begin
    if (OMUX_NOTZ = true) then
      if ((not z) = '0') then
        do <= (others => '0');
      else
        do <= regs_oupt(to_integer(unsigned(address)));
      end if;
    else
      do <= regs_oupt(to_integer(unsigned(address)));
    end if;
  end process;

  addr_dec : gen_decoder generic map (NI => ADDR_WDTH, NO => 2 ** ADDR_WDTH, EN => true)
    port map (input => address, e => z, output => regs_en);

  -- Generate 2^ADDR_WDTH registers
  r_gen : for i in 0 to (2 ** ADDR_WDTH) - 1 generate
    ri : my_rege generic map (N => DI_WDTH)
      port map (clock => clock, resetn => resetn, E => regs_en(i), sclr => '0',
                D     => regs_inpt(i), Q => regs_oupt(i));
  end generate;

end structural;
