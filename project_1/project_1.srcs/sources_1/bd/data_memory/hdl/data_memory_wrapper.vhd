--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Thu Apr  4 13:46:30 2024
--Host        : alterego-lte running 64-bit Arch Linux
--Command     : generate_target data_memory_wrapper.bd
--Design      : data_memory_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity data_memory_wrapper is
end data_memory_wrapper;

architecture STRUCTURE of data_memory_wrapper is
  component data_memory is
  end component data_memory;
begin
data_memory_i: component data_memory
 ;
end STRUCTURE;
