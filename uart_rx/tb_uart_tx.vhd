
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_uart_tx IS
END tb_uart_tx;
 
ARCHITECTURE behavior OF tb_uart_tx IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_tx
    PORT(
         resetn : IN  std_logic;
         clock : IN  std_logic;
         E : IN  std_logic;
         SW : IN  std_logic_vector(7 downto 0);
         TXD : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal resetn : std_logic := '0';
   signal clock : std_logic := '0';
   signal E : std_logic := '0';
   signal SW : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal TXD : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uart_tx PORT MAP (
          resetn => resetn,
          clock => clock,
          E => E,
          SW => SW,
          TXD => TXD
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		resetn  <= '1';
      wait for clock_period*10;
		E <= '1'; SW <= x"E5"; wait for clock_period*6;
		E <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
