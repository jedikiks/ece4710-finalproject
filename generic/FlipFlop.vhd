---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2014).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Flip flop with asynchronous inputs clrn and prn (both active low)
--  as well as synchronous enable and clear (both active high)
-- E = '1', sclr = '0' --> Input data 'D' is copied on Q
-- E = '1', sclr = '1' --> Q is cleared (0)
entity FlipFlop is
    Port ( d : in  STD_LOGIC;
	        clrn: in std_logic:= '1';
			  prn: in std_logic:= '1';
           clk : in  STD_LOGIC;
			  ena: in std_logic;
			  sclr: in std_logic;
           q : out  STD_LOGIC);
end FlipFlop;

architecture behaviour of FlipFlop is

begin
	process (clk, ena, prn, clrn)
	begin
		if clrn = '0' then
			q <= '0';
		elsif prn = '0' then
			q <= '1';
		elsif (clk'event and clk='1') then
			if ena = '1' then
			    if sclr = '1' then
			         q <= '0';
			    else
			         q <= d;
			    end if;
			end if;
		end if;
	end process;

end behaviour;