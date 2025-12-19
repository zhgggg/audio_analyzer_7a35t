//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Wed Dec 17 09:32:25 2025
//Host        : zhg213 running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (aclk,
    ad_busy_0,
    ad_convst_0,
    ad_cs_0,
    ad_data_in_0,
    ad_rd_0,
    ad_reset_0,
    agc_enable_0,
    aresetn,
    fft_valid,
    measure_done,
    seg,
    sel,
    sw_points_0,
    uart_tx_0);
  input aclk;
  input ad_busy_0;
  output ad_convst_0;
  output ad_cs_0;
  input [15:0]ad_data_in_0;
  output ad_rd_0;
  output ad_reset_0;
  input agc_enable_0;
  input aresetn;
  output fft_valid;
  output measure_done;
  output [7:0]seg;
  output [5:0]sel;
  input [1:0]sw_points_0;
  output uart_tx_0;

  wire aclk;
  wire ad_busy_0;
  wire ad_convst_0;
  wire ad_cs_0;
  wire [15:0]ad_data_in_0;
  wire ad_rd_0;
  wire ad_reset_0;
  wire agc_enable_0;
  wire aresetn;
  wire fft_valid;
  wire measure_done;
  wire [7:0]seg;
  wire [5:0]sel;
  wire [1:0]sw_points_0;
  wire uart_tx_0;

  design_1 design_1_i
       (.aclk(aclk),
        .ad_busy_0(ad_busy_0),
        .ad_convst_0(ad_convst_0),
        .ad_cs_0(ad_cs_0),
        .ad_data_in_0(ad_data_in_0),
        .ad_rd_0(ad_rd_0),
        .ad_reset_0(ad_reset_0),
        .agc_enable_0(agc_enable_0),
        .aresetn(aresetn),
        .fft_valid(fft_valid),
        .measure_done(measure_done),
        .seg(seg),
        .sel(sel),
        .sw_points_0(sw_points_0),
        .uart_tx_0(uart_tx_0));
endmodule
