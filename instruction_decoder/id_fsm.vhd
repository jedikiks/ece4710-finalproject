library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity id_fsm is
  generic (
    IR_BITS : integer := 18;
    -- Datapath
    FS_BITS : integer := 5;
    DR_BITS : integer := 4;
    SR_BITS : integer := 4;
    MD_BITS : integer := 2);
  port (
    IR                                              : in  std_logic_vector (IR_BITS - 1 downto 0);
    clock, resetn, Z, C,
    IE, E_PC, INT_P                                 : in  std_logic;
    INT_ACK                                         : out std_logic;
    -- Program Counter Signals
    JS                                              : out std_logic_vector (1 downto 0);
    EPC, SS                                         : out std_logic;
    -- Datapath Signals
    DR                                              : out std_logic_vector (DR_BITS - 1 downto 0);
    SR                                              : out std_logic_vector (SR_BITS - 1 downto 0);
    MD                                              : out std_logic_vector (MD_BITS - 1 downto 0);
    fs                                              : out std_logic_vector (FS_BITS - 1 downto 0);
    RW, MA, MA_sclr, SIE, LIE, INTP, RI, RS, WS, MB : out std_logic;
    -- Data Memory Signals
    DM_WE                                           : out std_logic;
    -- Stack Signals
    we, en, sclr                                    : out std_logic);
end id_fsm;

architecture behavioral of id_fsm is
  type state is (S1, S2, S3, S4);
  signal y : state;

  signal opcode : std_logic_vector (17 downto 12);

begin
  opcode <= ir (17 downto 12);

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

  outputs : process (y, opcode, E_PC)
  begin
    INT_ACK <= '0';
    -- PC defaults
    JS      <= "11";
    SS      <= '0';
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

    case y is
      when S1 =>                        -- Initializers
        if E_PC = '1' then
          -- Start stack at 31
          sclr <= '1';
          en   <= '1';
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
            SR  <= IR(7 downto 4);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "011001" =>              -- ADD sX, sY
            -- Datapath
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "011011" =>              -- ADDCY sX, sY
            -- Datapath
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "011101" =>              -- SUB sX, sY
            -- Datapath
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "011111" =>              -- SUBCY sX, sY
            -- Datapath
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "010101" =>              -- COMPARE sX, sY
            -- Datapath
            SR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "001011" =>              -- AND sX, sY
            -- Datapath
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "001101" =>              -- OR sX, sY
            -- Datapath
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "001111" =>              -- XOR sX, sY
            -- Datapath
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "010011" =>              -- TEST sX, sY
            -- Datapath
            SR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "000111" =>              -- FETCH sX, (sY)
            -- Datapath
            SR  <= IR(7 downto 4);
            DR  <= IR(11 downto 8);
            RW  <= '1';
            MD  <= "10";
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "101111" =>              -- STORE sX, (sY)
            -- Datapath
            SR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "000101" =>              -- INPUT sX, (sY)
            -- Datapath
            DR  <= IR(11 downto 8);
            MD  <= "01";
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "101101" =>              -- OUTPUT sX, (sY) FIXME: register bug
            SR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          --===============================================
          --                  IM-type
          --===============================================
          when "000000" =>              -- LOAD sX, kk
            -- Datapath
            DR      <= IR(11 downto 8);
            MA_sclr <= '1';
            MA      <= '1';
            MB      <= '1';
            -- PC
            JS      <= "11";
            EPC     <= '1';

          when "011000" =>              -- ADD sX, kk
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "011010" =>              -- ADDCY sX, kk
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "011100" =>              -- SUB sX, kk
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "011110" =>              -- SUBCY sX, kk
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "010100" =>              -- COMPARE sX, kk
            -- Datapath
            SR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "001010" =>              -- AND sX, kk
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "001100" =>              -- OR sX, kk
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "001110" =>              -- XOR sX, kk
            SR  <= IR(11 downto 8);
            DR  <= IR(11 downto 8);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "010010" =>              -- TEST sX, kk
            SR  <= IR(11 downto 8);
            MA  <= '1';
            MB  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "000110" =>              -- FETCH sX, ss
            -- Datapath
            MB  <= '1';
            DR  <= IR(11 downto 8);
            MD  <= "10";
            RW  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "101110" =>              -- STORE sX, ss
            -- Datapath
            SR  <= IR(11 downto 8);
            MA  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "000100" =>              -- INPUT sX, kk
            -- Datapath
            DR  <= IR(11 downto 8);
            RW  <= '1';
            MD  <= "01";
            -- PC
            JS  <= "11";
            EPC <= '1';

          when "101100" =>              -- OUTPUT sX, kk
            -- Datapath
            SR  <= IR(11 downto 8);
            MB  <= '1';
            -- PC
            JS  <= "11";
            EPC <= '1';

          --===============================================
          --                  SR-type
          --===============================================
          when "100000" =>              -- Shift/Rotate extensions
            case ir(7 downto 0) is
              when "00000000" =>        -- RL sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "00000001" =>        -- RR sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "00000010" =>        -- SL0 sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "00000011" =>        -- SL1 sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "00000100" =>        -- SLA sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "00000101" =>        -- SLX sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "00000110" =>        -- SR0 sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "00000111" =>        -- SR1 sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "00001000" =>        -- SRA sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "00001001" =>        -- SRX sX
                -- Datapath
                DR  <= IR(11 downto 8);
                SR  <= IR(11 downto 8);
                MA  <= '1';
                -- PC
                JS  <= "11";
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
            JS  <= "00";
            EPC <= '1';

          when "110001" =>              -- CALL extensions: with flags
            case ir(11 downto 10) is
              when "00" =>              -- CALL C, aaa
                if C = '1' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "00";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;

              when "01" =>              -- CALL NC, aaa
                if C = '0' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "00";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;

              when "10" =>              -- CALL Z, aaa
                if Z = '1' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "00";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;

              when "11" =>              -- CALL NZ, aaa
                if Z = '0' then
                  -- Stack
                  en  <= '1';
                  we  <= '1';
                  -- PC
                  JS  <= "00";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;
              when others =>
            end case;

          when "110100" =>              -- JUMP aaa
            -- PC
            JS  <= "00";
            EPC <= '1';

          when "110101" =>              -- JUMP extensions: with flags
            case ir(11 downto 10) is
              when "00" =>              -- JUMP C, aaa
                if C = '1' then
                  -- PC
                  JS  <= "00";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;

              when "01" =>              -- JUMP NC, aaa
                if C = '0' then
                  -- PC
                  JS  <= "00";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;

              when "10" =>              -- JUMP Z, aaa
                if Z = '1' then
                  -- PC
                  JS  <= "00";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;

              when "11" =>              -- CALL NZ, aaa
                if Z = '0' then
                  -- PC
                  JS  <= "00";
                  EPC <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;
              when others =>
            end case;

          --===============================================
          --                  RET-type
          --===============================================
          when "101010" =>              -- RETURN
            -- PC
            SS  <= '1';
            JS  <= "11";
            EPC <= '1';
            -- Stack
            en  <= '1';

          when "101011" =>              -- RETURN extensions: with flags
            case ir(11 downto 0) is
              when "000000000000" =>    -- RETURN C
                if C = '1' then
                  -- PC
                  SS  <= '1';
                  JS  <= "11";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;

              when "000000000001" =>    -- RETURN NC
                if C = '0' then
                  -- PC
                  SS  <= '1';
                  JS  <= "11";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;

              when "000000000010" =>    -- RETURN Z
                if Z = '1' then
                  -- PC
                  SS  <= '1';
                  JS  <= "11";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;

              when "000000000011" =>    -- RETURN NZ
                if Z = '0' then
                  -- PC
                  SS  <= '1';
                  JS  <= "11";
                  EPC <= '1';
                  -- Stack
                  en  <= '1';
                else
                  -- PC
                  JS  <= "11";
                  EPC <= '1';
                end if;
              when others =>
            end case;

          when "111100" =>              -- ENABLE/DISABLE interrupt ext
            case ir(11 downto 0) is
              when "000000000000" =>    -- DISABLE INTERRUPT
                -- Datapath
                SIE <= '0';
                LIE <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';

              when "000000000001" =>    -- ENABLE INTERRUPT
                -- Datapath
                SIE <= '1';
                LIE <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';
              when others =>
            end case;

          when "111000" =>              -- RETURNI ENABLE/DISABLE interrupt ext
            case ir(11 downto 0) is
              when "000000000000" =>    -- RETURNI DISABLE
                -- Datapath
                SIE <= '0';
                LIE <= '1';
                RI  <= '1';
                -- PC
                JS  <= "01";
                EPC <= '1';
                -- Stack
                en  <= '1';

              when "000000000001" =>    -- RETURNI ENABLE
                -- Datapath
                SIE <= '1';
                LIE <= '1';
                RI  <= '1';
                -- PC
                JS  <= "11";
                EPC <= '1';
              when others =>
            end case;

          when others =>
        end case;

      when S3 =>  -- Second half of instructions (if needed)
        if INT_P = '1' then
          -- CALL 0x3FF:
          -- Stack
          en  <= '1';
          we  <= '1';
          -- PC
          JS  <= "10";
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
            SR <= IR(7 downto 4);
            DR <= IR(11 downto 8);
            RW <= '1';

          when "011001" =>              -- ADD sX, sY
            -- Datapath
            fs <= "00001";
            SR <= IR(7 downto 4);
            DR <= IR(11 downto 8);
            RW <= '1';

          when "011011" =>              -- ADDCY sX, sY
            -- Datapath
            fs <= "00010";
            SR <= IR(7 downto 4);
            DR <= IR(11 downto 8);
            RW <= '1';

          when "011101" =>              -- SUB sX, sY
            -- Datapath
            fs <= "00100";
            SR <= IR(7 downto 4);
            DR <= IR(11 downto 8);
            RW <= '1';

          when "011111" =>              -- SUBCY sX, sY
            -- Datapath
            fs <= "00101";
            SR <= IR(7 downto 4);
            DR <= IR(11 downto 8);
            RW <= '1';

          when "010101" =>              -- COMPARE sX, sY
            -- Datapath
            SR <= IR(7 downto 4);
            fs <= "00100";

          when "001011" =>              -- AND sX, sY
            -- Datapath
            fs <= "01000";
            SR <= IR(7 downto 4);
            DR <= IR(11 downto 8);
            RW <= '1';

          when "001101" =>              -- OR sX, sY
            -- Datapath
            fs <= "01001";
            SR <= IR(7 downto 4);
            DR <= IR(11 downto 8);
            RW <= '1';

          when "001111" =>              -- XOR sX, sY
            -- Datapath
            fs <= "01010";
            SR <= IR(7 downto 4);
            DR <= IR(11 downto 8);
            RW <= '1';

          when "010011" =>              -- TEST sX, sY
            -- Datapath
            fs <= "01010";
            SR <= IR(7 downto 4);

          when "000111" =>              -- FETCH sX, (sY)
            -- Datapath
            DR <= IR(11 downto 8);
            MD <= "10";

          when "101111" =>              -- STORE sX, (sY)
            SR    <= IR(7 downto 4);
            DM_WE <= '1';

          when "000101" =>              -- INPUT sX, (sY)
            -- Datapath
            SR <= IR(7 downto 4);

          when "101101" =>              -- OUTPUT sX, (sY) FIXME: register bug
            SR <= IR(7 downto 4);

          --===============================================
          --                  IM-type
          --===============================================
          when "000000" =>              -- LOAD sX, kk
            -- Datapath
            DR <= IR(11 downto 8);
            RW <= '1';
            fs <= "00001";
            MB <= '1';

          when "011000" =>              -- ADD sX, kk
            -- Datapath
            DR <= IR(11 downto 8);
            RW <= '1';
            fs <= "00001";
            MB <= '1';

          when "011010" =>              -- ADDCY sX, kk
            -- Datapath
            DR <= IR(11 downto 8);
            RW <= '1';
            fs <= "00010";
            MB <= '1';

          when "011100" =>              -- SUB sX, kk
            -- Datapath
            DR <= IR(11 downto 8);
            RW <= '1';
            fs <= "00100";
            MB <= '1';

          when "011110" =>              -- SUBCY sX, kk
            -- Datapath
            DR <= IR(11 downto 8);
            RW <= '1';
            fs <= "00101";
            MB <= '1';

          when "010100" =>              -- COMPARE sX, kk
            -- Datapath
            SR <= IR(11 downto 8);
            MB <= '1';
            fs <= "00100";

          when "001010" =>              -- AND sX, kk
            -- Datapath
            DR <= IR(11 downto 8);
            RW <= '1';
            fs <= "01000";
            MB <= '1';

          when "001100" =>              -- OR sX, kk
            -- Datapath
            DR <= IR(11 downto 8);
            RW <= '1';
            fs <= "01001";
            MB <= '1';

          when "001110" =>              -- XOR sX, kk
            -- Datapath
            DR <= IR(11 downto 8);
            RW <= '1';
            fs <= "01010";
            MB <= '1';

          when "010010" =>              -- TEST sX, kk
            -- Datapath
            SR <= IR(11 downto 8);
            fs <= "01010";
            MB <= '1';

          when "000110" =>              -- FETCH sX, ss
            -- Datapath
            MB <= '1';
            DR <= IR(11 downto 8);
            MD <= "10";

          when "101110" =>              -- STORE sX, ss
            -- Datapath
            MB    <= '1';
            DM_WE <= '1';
            SR    <= IR(11 downto 8);

          when "000100" =>              -- INPUT sX, kk FIXME: possible bug
            -- Datapath
            MB <= '1';

          when "101100" =>              -- OUTPUT sX, kk
            -- Datapath
            SR <= IR(11 downto 8);
            MB <= '1';

          --===============================================
          --                  SR-type
          --===============================================
          when "100000" =>              -- Barrel instr, ext dependent
            case ir(7 downto 0) is
              when "00000000" =>        -- RL sX
                -- Datapath
                fs <= "10101";
                DR <= IR(11 downto 8);
                RW <= '1';

              when "00000001" =>        -- RR sX
                -- Datapath
                fs <= "10110";
                DR <= IR(11 downto 8);
                RW <= '1';

              when "00000010" =>        -- SL0 sX
                -- Datapath
                fs <= "01101";
                DR <= IR(11 downto 8);
                RW <= '1';

              when "00000011" =>        -- SL1 sX
                -- Datapath
                fs <= "01110";
                DR <= IR(11 downto 8);
                RW <= '1';

              when "00000100" =>        -- SLA sX
                -- Datapath
                fs <= "01111";
                DR <= IR(11 downto 8);
                RW <= '1';

              when "00000101" =>        -- SLX sX
                -- Datapath
                fs <= "10000";
                DR <= IR(11 downto 8);
                RW <= '1';

              when "00000110" =>        -- SR0 sX
                -- Datapath
                fs <= "10001";
                DR <= IR(11 downto 8);
                RW <= '1';

              when "00000111" =>        -- SR1 sX
                -- Datapath
                fs <= "10010";
                DR <= IR(11 downto 8);
                RW <= '1';

              when "00001000" =>        -- SRA sX
                -- Datapath
                fs <= "10100";
                DR <= IR(11 downto 8);
                RW <= '1';

              when "00001001" =>        -- SRX sX
                -- Datapath
                fs <= "10011";
                DR <= IR(11 downto 8);
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
