library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity uart_output is
    port (resetn, clock : in  std_logic;
          rdy           : in  std_logic;
          din           : in  std_logic_vector (31 downto 0);
          TXD           : out std_logic);
end uart_output;

architecture structural of uart_output is
    component uart_output_fsm is
        port (
            resetn : in  std_logic;
            clock  : in  std_logic;
            rdy    : in  std_logic;
            zG     : in  std_logic;
            done   : in  std_logic;
            s_l    : out std_logic;
            E_out  : out std_logic;
            EG     : out std_logic;
            sclrG  : out std_logic;
            E      : out std_logic);
    end component uart_output_fsm;

    component uart_rx is
        port (
            resetn, clock : in  std_logic;
            E             : in  std_logic;
            SW            : in  std_logic_vector (7 downto 0);
            TXD, done     : out std_logic);
    end component uart_rx;

    component my_genpulse_sclr is
        generic (
            COUNT : integer);
        port (
            clock, resetn, E, sclr : in  std_logic;
            Q                      : out std_logic_vector (integer(ceil(log2(real(COUNT)))) - 1 downto 0);
            z                      : out std_logic);
    end component my_genpulse_sclr;

    component my_pashiftreg
        generic (N   : integer := 4;
                 DIR : string  := "LEFT");
        port (clock, resetn : in  std_logic;
              din, E, s_l   : in  std_logic;  -- din: shiftin input
              D             : in  std_logic_vector (N-1 downto 0);
              Q             : out std_logic_vector (N-1 downto 0);
              shiftout      : out std_logic);
    end component;

    signal dout, done, E_out, s_l, EG, sclrG, zG, E, sel : std_logic;
    signal lut_out, data_rx                              : std_logic_vector (7 downto 0);

begin
    -- Bit comparator
    --cmp_out <= '1' when dout = '1' else '0';

    with sel select
        data_rx <= lut_out when '0',
        x"0A"            when others;


    -- Bit to ascii LUT
    with dout select
        lut_out <= x"31" when '1',
        x"30"            when others;

-- Shift Registers
    sa : my_pashiftreg generic map (N => 32, DIR => "RIGHT")
        port map (clock => clock, resetn => resetn, din => '0', E => E_out, s_l => s_l,
                  D     => din, shiftout => dout);

-- Counter: 32
    my_genpulse_sclr_1 : my_genpulse_sclr
        generic map (
            COUNT => 32)
        port map (
            clock  => clock,
            resetn => resetn,
            E      => EG,
            sclr   => sclrG,
            z      => zG);

    uart_rx_1 : uart_rx
        port map (
            resetn => resetn,
            clock  => clock,
            E      => E,
            SW     => data_rx,
            done   => done,
            TXD    => TXD);

    uart_output_fsm_1 : uart_output_fsm
        port map (
            resetn => resetn,
            clock  => clock,
            rdy    => rdy,
            zG     => zG,
            done   => done,
            s_l    => s_l,
            E_out  => E_out,
            EG     => EG,
            sclrG  => sclrG,
            E      => E);
end structural;
