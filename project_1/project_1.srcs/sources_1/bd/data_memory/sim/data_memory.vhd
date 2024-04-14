--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Thu Apr  4 13:46:30 2024
--Host        : alterego-lte running 64-bit Arch Linux
--Command     : generate_target data_memory.bd
--Design      : data_memory
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity data_memory is
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of data_memory : entity is "data_memory,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=data_memory,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of data_memory : entity is "data_memory.hwdef";
end data_memory;

architecture STRUCTURE of data_memory is
  component data_memory_blk_mem_gen_0_0 is
  port (
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 31 downto 0 );
    clkb : in STD_LOGIC;
    enb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component data_memory_blk_mem_gen_0_0;
  signal NLW_blk_mem_gen_0_douta_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_blk_mem_gen_0_doutb_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
begin
blk_mem_gen_0: component data_memory_blk_mem_gen_0_0
     port map (
      addra(9 downto 0) => B"0000000000",
      addrb(9 downto 0) => B"0000000000",
      clka => '0',
      clkb => '0',
      dina(31 downto 0) => B"00000000000000000000000000001000",
      dinb(31 downto 0) => B"00000000000000000000000000001000",
      douta(31 downto 0) => NLW_blk_mem_gen_0_douta_UNCONNECTED(31 downto 0),
      doutb(31 downto 0) => NLW_blk_mem_gen_0_doutb_UNCONNECTED(31 downto 0),
      ena => '0',
      enb => '0',
      wea(0) => '0',
      web(0) => '0'
    );
end STRUCTURE;
