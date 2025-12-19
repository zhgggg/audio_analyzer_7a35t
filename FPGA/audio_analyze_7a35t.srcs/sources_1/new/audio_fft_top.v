`timescale 1ns / 1ps

module audio_fft_top #(
    parameter CLK_FREQ = 50_000_000,
    parameter SAMPLE_RATE = 48_000
)(
    input wire        clk,
    input wire        rst_n,
    
    
    input wire        ad_busy,
    input wire [15:0] ad_data_in,
    output wire       ad_cs,
    output wire       ad_rd,
    output wire       ad_reset,
    output wire       ad_convst,
    
    
    input wire [1:0]  fft_size_cfg  
);

    
    wire        sample_valid;
    wire [15:0] sample_data;
    
    
    wire        fft_start;
    wire [15:0] fft_data_out;
    wire        fft_data_valid;
    wire        fft_data_last;
    wire [11:0] fft_point_cnt;
    
    
    wire [31:0] fft_result_real;
    wire [31:0] fft_result_imag;
    wire        fft_result_valid;
    wire        fft_result_last;
    
    
    (* mark_debug = "true" *) wire [15:0] peak_freq_hz;
    (* mark_debug = "true" *) wire [31:0] peak_magnitude;
    (* mark_debug = "true" *) wire [11:0] peak_bin;
    (* mark_debug = "true" *) wire        freq_valid;
    
    
    ad7606_driver #(
        .CLK_FREQ(CLK_FREQ),
        .SAMPLE_RATE(SAMPLE_RATE)
    ) u_ad7606_driver (
        .clk(clk),
        .rst_n(rst_n),
        .ad_busy(ad_busy),
        .ad_data_in(ad_data_in),
        .ad_cs(ad_cs),
        .ad_rd(ad_rd),
        .ad_reset(ad_reset),
        .ad_convst(ad_convst),
        .sample_valid(sample_valid),
        .sample_data_out(sample_data)
    );
    
    
    fft_data_buffer #(
        .MAX_FFT_POINTS(2048)
    ) u_fft_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .sample_valid(sample_valid),
        .sample_data(sample_data),
        .fft_size_cfg(fft_size_cfg),
        .fft_start(fft_start),
        .fft_data_out(fft_data_out),
        .fft_data_valid(fft_data_valid),
        .fft_data_last(fft_data_last),
        .fft_point_cnt(fft_point_cnt),
        .buffer_ready()
    );
    
    
    xfft_0 u_fft_ip (
        .aclk(clk),
        .aresetn(rst_n),
        .s_axis_config_tdata(fft_size_cfg),
        .s_axis_config_tvalid(fft_start),
        .s_axis_config_tready(),
        .s_axis_data_tdata({16'h0, fft_data_out}),
        .s_axis_data_tvalid(fft_data_valid),
        .s_axis_data_tready(),
        .s_axis_data_tlast(fft_data_last),
        .m_axis_data_tdata({fft_result_imag, fft_result_real}),
        .m_axis_data_tvalid(fft_result_valid),
        .m_axis_data_tready(1'b1),
        .m_axis_data_tlast(fft_result_last),
        .event_frame_started(),
        .event_tlast_unexpected(),
        .event_tlast_missing(),
        .event_data_in_channel_halt()
    );
    
    
    fft_freq_analyzer #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .MAX_FFT_POINTS(2048)
    ) u_freq_analyzer (
        .clk(clk),
        .rst_n(rst_n),
        .fft_result_real(fft_result_real),
        .fft_result_imag(fft_result_imag),
        .fft_result_valid(fft_result_valid),
        .fft_result_last(fft_result_last),
        .fft_points(fft_point_cnt),
        .peak_freq_hz(peak_freq_hz),
        .peak_magnitude(peak_magnitude),
        .peak_bin(peak_bin),
        .analysis_done(freq_valid)
    );

endmodule
