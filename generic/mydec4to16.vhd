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

entity mydec4to16 is
	port ( DR: in std_logic_vector (3 downto 0);
	       RW: in std_logic;
		   E: out std_logic_vector (15 downto 0));
end mydec4to16;

architecture struct of mydec4to16 is
    
    component mydec2to4
	port ( w: in std_logic_vector (1 downto 0);
	       E: in std_logic;
			 y: out std_logic_vector (3 downto 0));
    end component;

    signal yt: std_logic_vector (3 downto 0);
    
begin

    ti: mydec2to4 port map (w => DR(3 downto 2), E => RW, y => yt);
	ta: mydec2to4 port map (w => DR(1 downto 0), E => yt(0), y => E(3 downto 0));
	tb: mydec2to4 port map (w => DR(1 downto 0), E => yt(1), y => E(7 downto 4));
	tc: mydec2to4 port map (w => DR(1 downto 0), E => yt(2), y => E(11 downto 8));
	td: mydec2to4 port map (w => DR(1 downto 0), E => yt(3), y => E(15 downto 12));
	        
end struct;