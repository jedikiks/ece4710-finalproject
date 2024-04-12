library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interrupt_fsm is
  port (clock, resetn, INT, IE : in  std_logic;
        INT_P                  : out std_logic);
end interrupt_fsm;

architecture behavioral of interrupt_fsm is

  type state is (S1, S2);
  signal y : state;

  signal intpulse_cnt : integer;

begin
  transitions : process (resetn, clock)
  begin
    if resetn = '0' then
      y <= S1; intpulse_cnt <= 0;
    elsif (clock'event and clock = '1') then
      case y is
        when S1 =>
          if INT = '1' then
            if IE = '1' then
              if intpulse_cnt = 2 then
                intpulse_cnt <= 0;
                y            <= S2;
              else
                intpulse_cnt <= intpulse_cnt + 1;
                y            <= S1;
              end if;
            else
              y <= S1;
            end if;
          else
            y <= S1;
          end if;
        when S2 =>
          y <= S1;
      end case;
    end if;
  end process;

  outputs : process (y, INT, IE, intpulse_cnt)
  begin
    INT_P <= '0';

    case y is
      when S1 =>
      when S2 =>
        INT_P <= '1';
    end case;
  end process;
end behavioral;
