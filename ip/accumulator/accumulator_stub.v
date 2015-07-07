// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.2 (win64) Build 932637 Wed Jun 11 13:33:10 MDT 2014
// Date        : Wed Jul 01 19:38:17 2015
// Host        : rhea running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/hikaru/readout/rhea/project_3/project_3.srcs/sources_1/ip/accumulator/accumulator_stub.v
// Design      : accumulator
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "c_accum_v12_0,Vivado 2014.2" *)
module accumulator(B, CLK, CE, SCLR, Q)
/* synthesis syn_black_box black_box_pad_pin="B[30:0],CLK,CE,SCLR,Q[55:0]" */;
  input [30:0]B;
  input CLK;
  input CE;
  input SCLR;
  output [55:0]Q;
endmodule
