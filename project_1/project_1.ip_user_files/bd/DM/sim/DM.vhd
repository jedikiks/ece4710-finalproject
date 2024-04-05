--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Tue Apr  2 14:06:15 2024
--Host        : alterego running 64-bit Arch Linux
--Command     : generate_target DM.bd
--Design      : DM
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity DM is
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of DM : entity is "DM,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=DM,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of DM : entity is "DM.hwdef";
end DM;

architecture STRUCTURE of DM is
  component DM_blk_mem_gen_0_0 is
  port (
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component DM_blk_mem_gen_0_0;
  signal NLW_blk_mem_gen_0_douta_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
begin
blk_mem_gen_0: component DM_blk_mem_gen_0_0
     port map (
      addra(9 downto 0) => B"0000000000",
      clka => '0',
      dina(31 downto 0) => B"00000000000000000000000000001000",
      douta(31 downto 0) => NLW_blk_mem_gen_0_douta_UNCONNECTED(31 downto 0),
      ena => '0',
      wea(0) => '0'
    );
end STRUCTURE;
