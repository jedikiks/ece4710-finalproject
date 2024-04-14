--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Tue Apr  2 14:06:15 2024
--Host        : alterego running 64-bit Arch Linux
--Command     : generate_target DM_wrapper.bd
--Design      : DM_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity DM_wrapper is
end DM_wrapper;

architecture STRUCTURE of DM_wrapper is
  component DM is
  end component DM;
begin
DM_i: component DM
 ;
end STRUCTURE;
