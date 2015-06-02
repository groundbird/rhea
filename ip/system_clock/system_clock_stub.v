// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.2 (win64) Build 932637 Wed Jun 11 13:33:10 MDT 2014
// Date        : Tue Jun 02 09:33:32 2015
// Host        : rhea running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/hikaru/readout/rhea/project_3/project_3.srcs/sources_1/ip/system_clock/system_clock_stub.v
// Design      : system_clock
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module system_clock(clk_in1_p, clk_in1_n, clk_out1, clk_out2, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_in1_p,clk_in1_n,clk_out1,clk_out2,reset,locked" */;
  input clk_in1_p;
  input clk_in1_n;
  output clk_out1;
  output clk_out2;
  input reset;
  output locked;
endmodule
