-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
-- Date        : Fri Jul 31 18:40:24 2015
-- Host        : rhea running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Users/hikaru/readout/rhea/project_3/project_3.srcs/sources_1/ip/accumulator/accumulator_stub.vhdl
-- Design      : accumulator
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity accumulator is
  Port ( 
    B : in STD_LOGIC_VECTOR ( 30 downto 0 );
    CLK : in STD_LOGIC;
    CE : in STD_LOGIC;
    SCLR : in STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 55 downto 0 )
  );

end accumulator;

architecture stub of accumulator is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "B[30:0],CLK,CE,SCLR,Q[55:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "c_accum_v12_0,Vivado 2015.2";
begin
end;
