-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.2 (win64) Build 932637 Wed Jun 11 13:33:10 MDT 2014
-- Date        : Thu Jun 25 11:20:27 2015
-- Host        : rhea running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Users/hikaru/readout/rhea/project_3/project_3.srcs/sources_1/ip/subtracter/subtracter_stub.vhdl
-- Design      : subtracter
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity subtracter is
  Port ( 
    A : in STD_LOGIC_VECTOR ( 29 downto 0 );
    B : in STD_LOGIC_VECTOR ( 29 downto 0 );
    CLK : in STD_LOGIC;
    S : out STD_LOGIC_VECTOR ( 30 downto 0 )
  );

end subtracter;

architecture stub of subtracter is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "A[29:0],B[29:0],CLK,S[30:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "c_addsub_v12_0,Vivado 2014.2";
begin
end;