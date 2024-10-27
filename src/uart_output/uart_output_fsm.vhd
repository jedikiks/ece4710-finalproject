library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity uart_output_fsm is
    port (resetn, clock, zG, done, rdy : in  std_logic;
          s_l, E_out, EG, sclrG, E, sel     : out std_logic);
end uart_output_fsm;

architecture Behavioral of uart_output_fsm is

    type state is (S1, S2, S3, S4, S5);
    signal y : state;

begin

    Transitions : process (resetn, clock)
    begin
        if resetn = '0' then            -- asynchronous signal
            y <= S1;          -- if resetn asserted, go to initial state: S1
        elsif (clock'event and clock = '1') then
            case y is
                when S1 =>
                    if rdy = '1' then
                        y <= S2;
                    else
                        y <= S1;
                    end if;

                when S2 =>
                    y <= S3;

                when S3 =>
                    if done = '1' then
                        if zG = '1' then
                            y <= S4;
                        else
                            y <= S2;
                        end if;
                    else
                        y <= S3;
                    end if;

                when S4 =>
                    y <= S5;
                when S5 =>
                    if done = '1' then
                        y <= S1;
                    else
                        y <= S5;
                    end if;

            end case;
        end if;
    end process;

    Outputs : process (y, zG, rdy, done)
    begin
        -- Initialization of FSM outputs:
        s_l <= '0'; E_out <= '0'; EG <= '0'; sclrG <= '0'; E <= '0'; sel <= '0';
        case y is
            when S1 =>
                sclrG <= '1';
                EG    <= '1';
                if rdy = '1' then
                    s_l   <= '1';
                    E_out <= '1';
                end if;

            when S2 =>
                E_out <= '1';
                E     <= '1';

            when S3 =>
                E <= '1';
                if done = '1' then
                    if zG = '0' then
                        EG <= '1';
                    end if;
                end if;

            when S4 =>
                E <= '1';
                E_out <= '1';
                sel <= '1';

            when S5 =>
                E <= '1';
        end case;
    end process;
end Behavioral;
