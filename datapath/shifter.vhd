library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shifter is
    generic (
        N           : integer := 8;                   -- Number of bits
        SHIFT_VALUE : integer := 1                -- Value to be shifted in (default is '1')
    );
    port (
        idata       : in  std_logic_vector(N-1 downto 0);  -- Input data
        dir         : in  std_logic;
        cin         : in  std_logic;                        -- Direction (0 for left, 1 for right)
        odata       : out std_logic_vector(N-1 downto 0)    -- Output data
    );
end entity shifter;

architecture Behavioral of shifter is


begin
    process(idata, dir, cin)
    begin
        case dir is
            when '0' =>
                if SHIFT_VALUE = 1 then  -- Shift left
                    odata <= idata(N - 2 downto 0) & '1';
                elsif SHIFT_VALUE = 0 then
                    odata <= idata(N - 2 downto 0) & '0';
                elsif SHIFT_VALUE = 2 then
                    odata <= idata(N - 2 downto 0) & idata(0);
                elsif SHIFT_VALUE = 3 then
                    odata <= idata(N - 2 downto 0) & cin;
                elsif SHIFT_VALUE = 4 then
                    odata <= idata(N - 2 downto 0) & idata(7);
                end if;
            when '1' =>
                if SHIFT_VALUE = 1 then  -- Shift right
                    odata <= '1' & idata(N - 1 downto 1);
                elsif SHIFT_VALUE = 0 then
                    odata <= '0' & idata(N - 1 downto 1);
                elsif SHIFT_VALUE = 2 then
                    odata <= idata(N - 1) & idata(N - 1 downto 1);
                elsif SHIFT_VALUE = 3 then
                    odata <= cin & idata(N - 1 downto 1);
                elsif SHIFT_VALUE = 4 then
                    odata <= idata(0) & idata(N - 1 downto 1);
                end if;
            when others =>
                odata <= (others => 'X');  -- Handle undefined direction
        end case;
    end process;
end architecture Behavioral;
