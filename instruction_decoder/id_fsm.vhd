library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity id_fsm is
  generic (
    IR_BITS : integer := 32;
    -- Datapath
    FS_BITS : integer := 5;
    DR_BITS : integer := 5;
    SR_BITS : integer := 5;
    MD_BITS : integer := 2);
  port (
    IR                         : in  std_logic_vector (IR_BITS - 1 downto 0);
    clock, resetn, E_PC, INT_P : in  std_logic;
    INT_ACK                    : out std_logic;
    -- Program Counter Signals
    SS                         : out std_logic_vector (1 downto 0);
    JS                         : out std_logic_vector (2 downto 0);
    EPC                        : out std_logic;
    -- Datapath Signals
    Z, V, N, C                 : in  std_logic;
    DR                         : out std_logic_vector (DR_BITS - 1 downto 0);
    SR                         : out std_logic_vector (SR_BITS - 1 downto 0);
    MD                         : out std_logic_vector (MD_BITS - 1 downto 0);
    fs                         : out std_logic_vector (FS_BITS - 1 downto 0);
    RW, MA, MA_sclr, SIE, LIE,
    INTP, RI, RS, WS, MB, Z_en,
    V_en, N_en, C_en           : out std_logic;
    -- Data Memory Signals
    DM_WE                      : out std_logic;
    -- Stack Signals
    we, en, sclr               : out std_logic);
end id_fsm;

architecture behavioral of id_fsm is
  type state is (S1, S2, S3, S4);
  signal y : state;

  signal opcode : std_logic_vector (5 downto 0);

begin
  opcode <= ir (31 downto 26);

  transitions : process (resetn, clock)
  begin
    if resetn = '0' then
      y <= S1;
    elsif (clock'event and clock = '1') then
      case y is
        when S1 =>                      -- For initializers, ex. stack reset
          if E_PC = '1' then
            y <= S2;
          else
            y <= S1;
          end if;
        when S2 => y <= S3;  -- First half of the instruction. PC is also updated here
        when S3 =>           -- Second half of the instruction (if needed)
          if INT_P = '1' then
            y <= S4;
          else
            y <= S2;
          end if;
        when S4 => y <= S2;
      end case;
    end if;
  end process;

  outputs : process (y, opcode, E_PC, Z, V, N, C, IR, INT_P)
  begin
    INT_ACK <= '0';
    -- PC defaults
    JS      <= "011";
    SS      <= "00";
    EPC     <= '0';
    -- Datapath defaults
    DR      <= (others => '0');
    SR      <= (others => '0');
    MD      <= (others => '0');
    fs      <= (others => '0');
    RW      <= '0';
    MB      <= '0';
    MA      <= '0';
    MA_sclr <= '0';
    SIE     <= '0';
    LIE     <= '0';
    INTP    <= '0';
    RI      <= '0';
    RS      <= '0';
    WS      <= '0';
    DM_WE   <= '0';
    WE      <= '0';
    EN      <= '0';
    sclr    <= '0';
    Z_en    <= '0';
    C_en    <= '0';
    V_en    <= '0';
    N_en    <= '0';

    case y is
      when S1 =>                        -- Initializers
        if E_PC = '1' then
          -- Start stack at 31
          sclr <= '1';
          en   <= '1';

          -- Clear flags
          Z_en    <= '0';
          C_en    <= '0';
          V_en    <= '0';
          N_en    <= '0';

          -- Disable interrupts
          SIE  <= '0';
          LIE  <= '1';
        end if;

      when S2 =>  -- First half of instructions. PC also gets updated here
        case opcode is
          --===============================================
          --                  R-type
          --===============================================
          when "000001" =>              -- LOAD sX, sY
            -- Datapath
            SR  <= IR(20 downto 16);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "011001" =>              -- ADD sX, sY
            -- Datapath
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "011011" =>              -- ADDCY sX, sY
            -- Datapath
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "011101" =>              -- SUB sX, sY
            -- Datapath
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "011111" =>              -- SUBCY sX, sY
            -- Datapath
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "010101" =>              -- COMPARE sX, sY
            -- Datapath
            SR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "001011" =>              -- AND sX, sY
            -- Datapath
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "001101" =>              -- OR sX, sY
            -- Datapath
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "001111" =>              -- XOR sX, sY
            -- Datapath
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "010011" =>              -- TEST sX, sY
            -- Datapath
            SR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "000111" =>              -- FETCH sX, (sY)
            -- Datapath
            SR  <= IR(20 downto 16);
            DR  <= IR(25 downto 21);
            RW  <= '1';
            MD  <= "10";
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "101111" =>              -- STORE sX, (sY)
            -- Datapath
            SR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "000101" =>              -- INPUT sX, (sY)
            -- Datapath
            DR  <= IR(25 downto 21);
            MD  <= "01";
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "101101" =>              -- OUTPUT sX, (sY) FIXME: register bug
            SR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          --===============================================
          --                  IM-type
          --===============================================
          when "000000" =>              -- LOAD sX, kk
            -- Datapath
            DR      <= IR(25 downto 21);
            MA_sclr <= '1';
            MA      <= '1';
            MB      <= '1';
            -- PC
            JS      <= "011";
            EPC     <= '1';

          when "011000" =>              -- ADD sX, kk
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "011010" =>              -- ADDCY sX, kk
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "011100" =>              -- SUB sX, kk
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "011110" =>              -- SUBCY sX, kk
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "010100" =>              -- COMPARE sX, kk
            -- Datapath
            SR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "001010" =>              -- AND sX, kk
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "001100" =>              -- OR sX, kk
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "001110" =>              -- XOR sX, kk
            SR  <= IR(25 downto 21);
            DR  <= IR(25 downto 21);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "010010" =>              -- TEST sX, kk
            SR  <= IR(25 downto 21);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "000110" =>              -- FETCH sX, ss
            -- Datapath
            MB  <= '1';
            DR  <= IR(25 downto 21);
            MD  <= "10";
            RW  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "101110" =>              -- STORE sX, ss
            -- Datapath
            SR  <= IR(25 downto 21);
            MA  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "000100" =>              -- INPUT sX, kk
            -- Datapath
            DR  <= IR(25 downto 21);
            RW  <= '1';
            MD  <= "01";
            -- PC
            JS  <= "011";
            EPC <= '1';

          when "101100" =>              -- OUTPUT sX, kk
            -- Datapath
            SR  <= IR(25 downto 21);
            MB  <= '1';
            -- PC
            JS  <= "011";
            EPC <= '1';

          --===============================================
          --                  SR-type
          --===============================================
          when "100000" =>              -- Shift/Rotate extensions
            case ir(7 downto 0) is
              when "00000000" =>        -- RL sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00000001" =>        -- RR sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00000010" =>        -- SL0 sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00000011" =>        -- SL1 sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00000100" =>        -- SLA sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00000101" =>        -- SLX sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00000110" =>        -- SR0 sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00000111" =>        -- SR1 sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00001000" =>        -- SRA sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00001001" =>        -- SRX sX
                -- Datapath
                DR  <= IR(25 downto 21);
                SR  <= IR(25 downto 21);
                MA  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when others =>
            end case;

          --===============================================
          --                  JMP-type
          --===============================================
          when "110000" =>              -- CALL aaa
            -- Stack
            en  <= '1';
            we  <= '1';
            -- PC
            JS  <= "000";
            EPC <= '1';

          when "110001" =>              -- CALL extensions: with flags
            case ir(25 downto 23) is
              when "000" =>             -- CALL Z, aaa
                if Z = '1' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "001" =>             -- CALL NZ, aaa
                if Z = '0' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "010" =>             -- CALL V, aaa
                if V = '1' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "011" =>             -- CALL NV, aaa
                if V = '0' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "100" =>             -- CALL N, aaa
                if N = '1' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "101" =>             -- CALL NN, aaa
                if N = '0' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "110" =>             -- CALL C, aaa
                if C = '1' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "111" =>             -- CALL NC, aaa
                if C = '0' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when others =>
            end case;

          when "110010" =>              -- BR offset
            -- PC
            JS  <= "100";
            EPC <= '1';

          when "110011" =>              -- BR extensions: with flags
            case ir(25 downto 23) is
              when "000" =>             -- BR Z, offset
                if Z = '1' then
                  -- PC
                  JS <= "100";

                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "001" =>             -- BR NZ, offset
                if Z = '0' then
                  -- PC
                  JS <= "100";

                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "010" =>             -- BR V, offset
                if V = '1' then
                  -- PC
                  JS <= "100";

                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "011" =>             -- BR NV, offset
                if V = '0' then
                  -- PC
                  JS <= "100";

                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "100" =>             -- BR N, offset
                if N = '1' then
                  -- PC
                  JS <= "100";

                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "101" =>             -- BR NN, offset
                if N = '0' then
                  -- PC
                  JS <= "100";

                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "110" =>             -- BR C, offset
                if C = '1' then
                  -- PC
                  JS <= "100";

                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "111" =>             -- BR NC, offset
                if C = '0' then
                  -- PC
                  JS <= "100";

                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when others =>
            end case;

          when "110100" =>              -- JUMP aaa
            -- PC
            JS  <= "000";
            EPC <= '1';

          when "110101" =>              -- JUMP extensions: with flags
            case ir(25 downto 23) is
              when "000" =>             -- JUMP Z, aaa
                if Z = '1' then
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "001" =>             -- JUMP NZ, aaa
                if Z = '0' then
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "010" =>             -- JUMP V, aaa
                if V = '1' then
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "011" =>             -- JUMP NV, aaa
                if V = '0' then
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "100" =>             -- JUMP N, aaa
                if N = '1' then
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "101" =>             -- JUMP NN, aaa
                if N = '0' then
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "110" =>             -- JUMP C, aaa
                if C = '1' then
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "111" =>             -- JUMP NC, aaa
                if C = '0' then
                  -- PC
                  JS  <= "000";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when others =>
            end case;

          --===============================================
          --                  RET-type
          --===============================================
          when "101010" =>              -- RETURN
            -- PC
            SS  <= "01";
            JS  <= "011";
            EPC <= '1';
            -- Stack
            en  <= '1';

          when "101011" =>              -- RETURN extensions: with flags
            case ir(25 downto 0) is
              when "00000000000000000000000000" =>  -- RETURN Z, aaa
                if Z = '1' then
                  -- PC
                  SS  <= "01";
                  JS  <= "011";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "00000000000000000000000001" =>  -- RETURN NZ, aaa
                if Z = '0' then
                  -- PC
                  SS  <= "01";
                  JS  <= "011";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "00000000000000000000000010" =>  -- RETURN V, aaa
                if V = '1' then
                  -- PC
                  SS  <= "01";
                  JS  <= "011";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "00000000000000000000000011" =>  -- RETURN NV, aaa
                if V = '0' then
                  -- PC
                  SS  <= "01";
                  JS  <= "011";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "00000000000000000000000100" =>  -- RETURN N, aaa
                if N = '1' then
                  -- PC
                  SS  <= "01";
                  JS  <= "011";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "00000000000000000000000101" =>  -- RETURN NN, aaa
                if N = '0' then
                  -- PC
                  SS  <= "01";
                  JS  <= "011";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "00000000000000000000000110" =>  -- RETURN C, aaa
                if C = '1' then
                  -- PC
                  SS  <= "01";
                  JS  <= "011";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;

              when "00000000000000000000000111" =>  -- RETURN NC, aaa
                if C = '0' then
                  -- PC
                  SS  <= "01";
                  JS  <= "011";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "011";
                  EPC <= '1';
                end if;
              when others =>
            end case;

          when "111100" =>              -- ENABLE/DISABLE interrupt ext
            case ir(25 downto 0) is
              when "00000000000000000000000000" =>  -- DISABLE INTERRUPT
                -- Datapath
                SIE <= '0';
                LIE <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';

              when "00000000000000000000000001" =>  -- ENABLE INTERRUPT
                -- Datapath
                SIE <= '1';
                LIE <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';
              when others =>
            end case;

          when "111000" =>              -- RETURNI ENABLE/DISABLE interrupt ext
            case ir(25 downto 0) is
              when "00000000000000000000000000" =>  -- RETURNI DISABLE
                -- Datapath
                SIE <= '0';
                LIE <= '1';
                RI  <= '1';
                -- PC
                JS  <= "001";
                EPC <= '1';
                -- Stack
                en  <= '1';

              when "00000000000000000000000001" =>  -- RETURNI ENABLE
                -- Datapath
                SIE <= '1';
                LIE <= '1';
                RI  <= '1';
                -- PC
                JS  <= "011";
                EPC <= '1';
              when others =>
            end case;

          when others =>
        end case;

      when S3 =>  -- Second half of instructions (if needed)
        Z_en    <= '1';
        C_en    <= '1';
        V_en    <= '1';
        N_en    <= '1';

        if INT_P = '1' then
          -- CALL 0x3FF:
          -- Stack
          en  <= '1';
          we  <= '1';
          -- PC
          JS  <= "010";
          EPC <= '1';

          -- Datapath
          SIE <= '0';
          LIE <= '1';
        end if;

        case opcode is
          --===============================================
          --                  R-type
          --===============================================
          when "000001" =>              -- LOAD sX, sY
            -- Datapath
            fs <= "00000";
            SR <= IR(20 downto 16);
            DR <= IR(25 downto 21);
            RW <= '1';

          when "011001" =>              -- ADD sX, sY
            -- Datapath
            fs <= "00001";
            SR <= IR(20 downto 16);
            DR <= IR(25 downto 21);
            RW <= '1';

          when "011011" =>              -- ADDCY sX, sY
            -- Datapath
            fs <= "00010";
            SR <= IR(20 downto 16);
            DR <= IR(25 downto 21);
            RW <= '1';

          when "011101" =>              -- SUB sX, sY
            -- Datapath
            fs <= "00100";
            SR <= IR(20 downto 16);
            DR <= IR(25 downto 21);
            RW <= '1';

          when "011111" =>              -- SUBCY sX, sY
            -- Datapath
            fs <= "00101";
            SR <= IR(20 downto 16);
            DR <= IR(25 downto 21);
            RW <= '1';

          when "010101" =>              -- COMPARE sX, sY
            -- Datapath
            SR <= IR(20 downto 16);
            fs <= "00100";

          when "001011" =>              -- AND sX, sY
            -- Datapath
            fs <= "01000";
            SR <= IR(20 downto 16);
            DR <= IR(25 downto 21);
            RW <= '1';

          when "001101" =>              -- OR sX, sY
            -- Datapath
            fs <= "01001";
            SR <= IR(20 downto 16);
            DR <= IR(25 downto 21);
            RW <= '1';

          when "001111" =>              -- XOR sX, sY
            -- Datapath
            fs <= "01010";
            SR <= IR(20 downto 16);
            DR <= IR(25 downto 21);
            RW <= '1';

          when "010011" =>              -- TEST sX, sY
            -- Datapath
            fs <= "01010";
            SR <= IR(20 downto 16);

          when "000111" =>              -- FETCH sX, (sY)
            -- Datapath
            DR <= IR(25 downto 21);
            MD <= "10";

          when "101111" =>              -- STORE sX, (sY)
            SR    <= IR(20 downto 16);
            DM_WE <= '1';

          when "000101" =>              -- INPUT sX, (sY)
            -- Datapath
            SR <= IR(20 downto 16);

          when "101101" =>              -- OUTPUT sX, (sY) FIXME: register bug
            SR <= IR(20 downto 16);

          --===============================================
          --                  IM-type
          --===============================================
          when "000000" =>              -- LOAD sX, kk
            -- Datapath
            DR <= IR(25 downto 21);
            RW <= '1';
            fs <= "00001";
            MB <= '1';

          when "011000" =>              -- ADD sX, kk
            -- Datapath
            DR <= IR(25 downto 21);
            RW <= '1';
            fs <= "00001";
            MB <= '1';

          when "011010" =>              -- ADDCY sX, kk
            -- Datapath
            DR <= IR(25 downto 21);
            RW <= '1';
            fs <= "00010";
            MB <= '1';

          when "011100" =>              -- SUB sX, kk
            -- Datapath
            DR <= IR(25 downto 21);
            RW <= '1';
            fs <= "00100";
            MB <= '1';

          when "011110" =>              -- SUBCY sX, kk
            -- Datapath
            DR <= IR(25 downto 21);
            RW <= '1';
            fs <= "00101";
            MB <= '1';

          when "010100" =>              -- COMPARE sX, kk
            -- Datapath
            SR <= IR(25 downto 21);
            MB <= '1';
            fs <= "00100";

          when "001010" =>              -- AND sX, kk
            -- Datapath
            DR <= IR(25 downto 21);
            RW <= '1';
            fs <= "01000";
            MB <= '1';

          when "001100" =>              -- OR sX, kk
            -- Datapath
            DR <= IR(25 downto 21);
            RW <= '1';
            fs <= "01001";
            MB <= '1';

          when "001110" =>              -- XOR sX, kk
            -- Datapath
            DR <= IR(25 downto 21);
            RW <= '1';
            fs <= "01010";
            MB <= '1';

          when "010010" =>              -- TEST sX, kk
            -- Datapath
            SR <= IR(25 downto 21);
            fs <= "01010";
            MB <= '1';

          when "000110" =>              -- FETCH sX, ss
            -- Datapath
            MB <= '1';
            DR <= IR(25 downto 21);
            MD <= "10";

          when "101110" =>              -- STORE sX, ss
            -- Datapath
            MB    <= '1';
            DM_WE <= '1';
            SR    <= IR(25 downto 21);

          when "000100" =>              -- INPUT sX, kk FIXME: possible bug
            -- Datapath
            MB <= '1';

          when "101100" =>              -- OUTPUT sX, kk
            -- Datapath
            SR <= IR(25 downto 21);
            MB <= '1';

          --===============================================
          --                  SR-type
          --===============================================
          when "100000" =>              -- Barrel instr, ext dependent
            case ir(7 downto 0) is
              when "00000000" =>        -- RL sX
                -- Datapath
                fs <= "10101";
                DR <= IR(25 downto 21);
                RW <= '1';

              when "00000001" =>        -- RR sX
                -- Datapath
                fs <= "10110";
                DR <= IR(25 downto 21);
                RW <= '1';

              when "00000010" =>        -- SL0 sX
                -- Datapath
                fs <= "01101";
                DR <= IR(25 downto 21);
                RW <= '1';

              when "00000011" =>        -- SL1 sX
                -- Datapath
                fs <= "01110";
                DR <= IR(25 downto 21);
                RW <= '1';

              when "00000100" =>        -- SLA sX
                -- Datapath
                fs <= "01111";
                DR <= IR(25 downto 21);
                RW <= '1';

              when "00000101" =>        -- SLX sX
                -- Datapath
                fs <= "10000";
                DR <= IR(25 downto 21);
                RW <= '1';

              when "00000110" =>        -- SR0 sX
                -- Datapath
                fs <= "10001";
                DR <= IR(25 downto 21);
                RW <= '1';

              when "00000111" =>        -- SR1 sX
                -- Datapath
                fs <= "10010";
                DR <= IR(25 downto 21);
                RW <= '1';

              when "00001000" =>        -- SRA sX
                -- Datapath
                fs <= "10100";
                DR <= IR(25 downto 21);
                RW <= '1';

              when "00001001" =>        -- SRX sX
                -- Datapath
                fs <= "10011";
                DR <= IR(25 downto 21);
                RW <= '1';

              when others =>
            end case;

          when others =>
        end case;

      when S4 =>
        INT_ACK <= '1';

    end case;
  end process;
end behavioral;
