---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity uart_tx is
	port (resetn, clock: in std_logic;
			E: in std_logic;
			SW: in std_logic_vector (7 downto 0);
			TXD: out std_logic);
end uart_tx;

architecture Behavioral of uart_tx is

	component my_genpulse
		generic (COUNT: INTEGER:= (10**8)/2); -- (10**8)/2 cycles of T = 10 ns --> 0.5 s
		port (clock, resetn, E: in std_logic;
				Q: out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
				z: out std_logic);
	end component;
	
	component my_pashiftreg
		generic (N: INTEGER:= 4;
					DIR: STRING:= "LEFT");
		port ( clock, resetn: in std_logic;
				 din, E, s_l: in std_logic; -- din: shiftin input
				 D: in std_logic_vector (N-1 downto 0);
				 Q: out std_logic_vector (N-1 downto 0);
				 shiftout: out std_logic);
	end component;
	
	type state is (S1, S2, S3, S4, S5);
	signal y: state;	
	
	signal SWQ: std_logic_vector (7 downto 0);
	signal EQ, zQ, zC, EC, ER, LR, so, Ei: std_logic;
	
begin

-- Counter: Modulo-8
gb: my_genpulse generic map (COUNT => 8) 
	 port map (clock => clock, resetn => resetn, E => EQ, z => zQ);

-- Counter: 1/9600 s
ga: my_genpulse generic map (COUNT => 10416) -- aprox, real one is 10416.6666
	 port map (clock => clock, resetn => resetn, E => EC, z => zC);
	
-- Shift Registers
sa: my_pashiftreg generic map (N => 8, DIR => "RIGHT")
    port map (clock => clock, resetn => resetn, din => '0', E => ER, s_l => LR, D => SW, shiftout => so);

-- 8-bit register
--ra: my_rege generic map (N => 8)
--	 port map (clock => clock, resetn => resetn, E => Ei, sclr => '0', D => SW, Q => SWQ);

	
-- Main FSM:
	Transitions: process (resetn, clock, zC, zQ, E)
	begin
		if resetn = '0' then -- asynchronous signal
			y <= S1; -- if resetn asserted, go to initial state: S1			
		elsif (clock'event and clock = '1') then
			case y is
				when S1 =>
					if E = '1' then y <= S1; else y <= S2; end if;
				
				when S2 =>
					if E = '1' then y <= S3; else y <= S2; end if;
				
				when S3 =>
					if zC = '1' then y <= S4; else y <= S3; end if;
					
				when S4 =>
					if zC = '1' then
						if zQ = '1' then y <= S5; else y <= S4; end if;
					else
						y <= S4;
					end if;
				
				when S5 =>
					if zC = '1' then y <= S1; else y <= S5; end if;
					
			end case;			
		end if;		
	end process;
	
	Outputs: process (y, so, zC, zQ, E)
	begin
		-- Initialization of FSM outputs:
		TXD <= '0'; ER <= '0'; LR <= '0'; EC <= '0'; EQ <= '0'; 
		case y is
			when S1 =>
				TXD <= '1';
				
			when S2 =>
				TXD <= '1';
				if E = '1' then LR <= '1'; ER <= '1'; end if;

			when S3 =>
				EC <= '1'; -- C <= C + 1 (or C <= 0 (if C reached max count))
			
			when S4 =>
				TXD <= so;
				if zC = '1' then -- C = N-1?
					EC <= '1'; -- C <= 0
					ER <= '1';
					EQ <= '1';	-- Q <=0 or Q <= Q+1					
				else
					EC <= '1'; -- C <= C+1
				end if;
			
			when S5 =>
				TXD <= '1';
				EC <= '1';
			
		end case;
	end process;
 
end Behavioral;

