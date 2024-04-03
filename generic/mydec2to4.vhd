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

entity mydec2to4 is
	port ( w: in std_logic_vector (1 downto 0);
	       E: in std_logic;
			 y: out std_logic_vector (3 downto 0));
end mydec2to4;

architecture struct of mydec2to4 is

	signal Ew: std_logic_vector (2 downto 0);
	
begin

	Ew <= E & w;
	with Ew select
		   y <= "0001" when "100",
			    "0010" when "101",
			    "0100" when "110",
			    "1000" when "111",
			    "0000" when others;
		  
	
end struct;

