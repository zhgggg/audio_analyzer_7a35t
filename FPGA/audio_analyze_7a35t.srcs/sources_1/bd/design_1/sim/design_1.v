//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Wed Dec 17 09:32:25 2025
//Host        : zhg213 running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=11,numReposBlks=11,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=8,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_RESET aresetn, CLK_DOMAIN design_1_aclk, FREQ_HZ 50000000, INSERT_VIP 0, PHASE 0.000" *) input aclk;
  input ad_busy_0;
  output ad_convst_0;
  output ad_cs_0;
  input [15:0]ad_data_in_0;
  output ad_rd_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.AD_RESET_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.AD_RESET_0, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output ad_reset_0;
  input agc_enable_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input aresetn;
  output fft_valid;
  output measure_done;
  output [7:0]seg;
  output [5:0]sel;
  input [1:0]sw_points_0;
  output uart_tx_0;

  wire aclk_1;
  wire ad7606_driver_0_ad_convst;
  wire ad7606_driver_0_ad_cs;
  wire ad7606_driver_0_ad_rd;
  wire ad7606_driver_0_ad_reset;
  wire [15:0]ad7606_driver_0_sample_data_out;
  wire ad7606_driver_0_sample_valid;
  wire ad_busy_0_1;
  wire [15:0]ad_data_in_0_1;
  wire [31:0]adc_to_fft_buffer_0_m_axis_TDATA;
  wire adc_to_fft_buffer_0_m_axis_TLAST;
  wire adc_to_fft_buffer_0_m_axis_TREADY;
  wire adc_to_fft_buffer_0_m_axis_TVALID;
  wire agc_enable_0_1;
  wire aresetn_1;
  wire auto_nrst_0_aresetn_out;
  wire [15:0]digital_agc_0_adc_data_out;
  wire [3:0]digital_agc_0_current_gain;
  wire [31:0]fft_freq_meter_0_freq_out;
  wire fft_freq_meter_0_measure_done;
  wire fft_sys_controller_0_o_force_rst;
  wire freq_screen_driver_0_uart_tx;
  wire [7:0]seg_driver_0_seg;
  wire [5:0]seg_driver_0_sel;
  wire [1:0]sw_points_0_1;
  wire [31:0]xfft_0_m_axis_data_tdata;
  wire xfft_0_m_axis_data_tvalid;
  wire [31:0]xlconcat_0_dout;
  wire [15:0]xlconstant_0_dout;

  assign aclk_1 = aclk;
  assign ad_busy_0_1 = ad_busy_0;
  assign ad_convst_0 = ad7606_driver_0_ad_convst;
  assign ad_cs_0 = ad7606_driver_0_ad_cs;
  assign ad_data_in_0_1 = ad_data_in_0[15:0];
  assign ad_rd_0 = ad7606_driver_0_ad_rd;
  assign ad_reset_0 = ad7606_driver_0_ad_reset;
  assign agc_enable_0_1 = agc_enable_0;
  assign aresetn_1 = aresetn;
  assign fft_valid = xfft_0_m_axis_data_tvalid;
  assign measure_done = fft_freq_meter_0_measure_done;
  assign seg[7:0] = seg_driver_0_seg;
  assign sel[5:0] = seg_driver_0_sel;
  assign sw_points_0_1 = sw_points_0[1:0];
  assign uart_tx_0 = freq_screen_driver_0_uart_tx;
  design_1_ad7606_driver_0_0 ad7606_driver_0
       (.ad_busy(ad_busy_0_1),
        .ad_convst(ad7606_driver_0_ad_convst),
        .ad_cs(ad7606_driver_0_ad_cs),
        .ad_data_in(ad_data_in_0_1),
        .ad_rd(ad7606_driver_0_ad_rd),
        .ad_reset(ad7606_driver_0_ad_reset),
        .clk(aclk_1),
        .rst_n(auto_nrst_0_aresetn_out),
        .sample_data_out(ad7606_driver_0_sample_data_out),
        .sample_valid(ad7606_driver_0_sample_valid));
  design_1_adc_to_fft_buffer_0_0 adc_to_fft_buffer_0
       (.aclk(aclk_1),
        .adc_data(xlconcat_0_dout),
        .adc_valid(ad7606_driver_0_sample_valid),
        .aresetn(auto_nrst_0_aresetn_out),
        .cfg_rst(fft_sys_controller_0_o_force_rst),
        .frame_length({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axis_tdata(adc_to_fft_buffer_0_m_axis_TDATA),
        .m_axis_tlast(adc_to_fft_buffer_0_m_axis_TLAST),
        .m_axis_tready(adc_to_fft_buffer_0_m_axis_TREADY),
        .m_axis_tvalid(adc_to_fft_buffer_0_m_axis_TVALID));
  design_1_auto_nrst_0_0 auto_nrst_0
       (.aresetn_out(auto_nrst_0_aresetn_out),
        .sys_clk(aclk_1),
        .sys_rst_n(aresetn_1));
  design_1_digital_agc_0_0 digital_agc_0
       (.adc_data_in(ad7606_driver_0_sample_data_out),
        .adc_data_out(digital_agc_0_adc_data_out),
        .agc_enable(agc_enable_0_1),
        .clk(aclk_1),
        .current_gain(digital_agc_0_current_gain),
        .rst_n(aresetn_1));
  design_1_fft_freq_meter_0_0 fft_freq_meter_0
       (.cfg_rst(1'b0),
        .clk(aclk_1),
        .fft_data(xfft_0_m_axis_data_tdata),
        .fft_valid(xfft_0_m_axis_data_tvalid),
        .freq_out(fft_freq_meter_0_freq_out),
        .measure_done(fft_freq_meter_0_measure_done),
        .rst_n(auto_nrst_0_aresetn_out),
        .sw_points(sw_points_0_1));
  design_1_fft_sys_controller_0_0 fft_sys_controller_0
       (.clk(aclk_1),
        .m_axis_config_tready(1'b1),
        .o_force_rst(fft_sys_controller_0_o_force_rst),
        .rst_n(auto_nrst_0_aresetn_out),
        .sw_points(sw_points_0_1));
  design_1_freq_screen_driver_0_0 freq_screen_driver_0
       (.agc_enable(agc_enable_0_1),
        .clk(aclk_1),
        .current_gain(digital_agc_0_current_gain),
        .data_in(fft_freq_meter_0_freq_out),
        .rst_n(aresetn_1),
        .uart_tx(freq_screen_driver_0_uart_tx));
  design_1_seg_driver_0_0 seg_driver_0
       (.clk(aclk_1),
        .data_in(fft_freq_meter_0_freq_out),
        .rst_n(aresetn_1),
        .seg(seg_driver_0_seg),
        .sel(seg_driver_0_sel));
  design_1_xfft_0_0 xfft_0
       (.aclk(aclk_1),
        .aresetn(auto_nrst_0_aresetn_out),
        .m_axis_data_tdata(xfft_0_m_axis_data_tdata),
        .m_axis_data_tready(1'b1),
        .m_axis_data_tvalid(xfft_0_m_axis_data_tvalid),
        .m_axis_status_tready(1'b1),
        .s_axis_config_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_config_tvalid(1'b0),
        .s_axis_data_tdata(adc_to_fft_buffer_0_m_axis_TDATA),
        .s_axis_data_tlast(adc_to_fft_buffer_0_m_axis_TLAST),
        .s_axis_data_tready(adc_to_fft_buffer_0_m_axis_TREADY),
        .s_axis_data_tvalid(adc_to_fft_buffer_0_m_axis_TVALID));
  design_1_xlconcat_0_0 xlconcat_0
       (.In0(digital_agc_0_adc_data_out),
        .In1(xlconstant_0_dout),
        .dout(xlconcat_0_dout));
  design_1_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule
