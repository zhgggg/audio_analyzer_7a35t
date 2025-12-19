`timescale 1ns / 1ps


module ad7606_driver #(
    parameter CLK_FREQ    = 50_000_000,
    parameter SAMPLE_RATE = 48_000
)(
    input             clk,
    input             rst_n,
    input             ad_busy,
    input      [15:0] ad_data_in,
    output reg        ad_cs,
    output reg        ad_rd,
    output reg        ad_reset,
    output reg        ad_convst,
    output reg        sample_valid,
    output reg [15:0] sample_data_out
    );

    localparam CNT_MAX = CLK_FREQ / SAMPLE_RATE;
    localparam S_IDLE       = 4'd0;
    localparam S_RESET_AD   = 4'd1;
    localparam S_WAIT_TRIG  = 4'd2;
    localparam S_CONV_START = 4'd3;
    localparam S_WAIT_BUSY  = 4'd4;
    localparam S_READ_SETUP = 4'd5;
    localparam S_READ_LOW   = 4'd6;
    localparam S_READ_LATCH = 4'd7;
    localparam S_READ_HIGH  = 4'd8;
    localparam S_DONE       = 4'd9;
     reg [3:0] state;
    reg [31:0] trig_cnt;
    reg [15:0] reset_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= S_IDLE;
            ad_cs           <= 1'b1;
            ad_rd           <= 1'b1;
            ad_reset        <= 1'b0;
            ad_convst       <= 1'b1;
            sample_valid    <= 1'b0;
            sample_data_out <= 16'd0;
            trig_cnt        <= 0;
            reset_cnt       <= 0;
        end else begin
            sample_valid <= 1'b0;
            if (trig_cnt < CNT_MAX - 1)
                trig_cnt <= trig_cnt + 1;
            else
                trig_cnt <= 0;

            case (state)
                S_IDLE: begin
                    state <= S_RESET_AD;
                    reset_cnt <= 0;
                end
                S_RESET_AD: begin
                    ad_reset <= 1'b1;
                    reset_cnt <= reset_cnt + 1;
                    if (reset_cnt > 16'd100) begin
                        ad_reset <= 1'b0;
                        state <= S_WAIT_TRIG;
                    end
                end
                S_WAIT_TRIG: begin
                    if (trig_cnt == 0)
                        state <= S_CONV_START;
                end
                S_CONV_START: begin
                    ad_convst <= 1'b0;
                    if (trig_cnt == 5) begin
                         ad_convst <= 1'b1;
                         state <= S_WAIT_BUSY;
                    end
                end
                S_WAIT_BUSY: begin
                    if (trig_cnt > 20 && ad_busy == 1'b0) begin
                        state <= S_READ_SETUP;
                    end
                end
                S_READ_SETUP: begin
                    ad_cs <= 1'b0;
                    state <= S_READ_LOW;
                end
                S_READ_LOW: begin
                    ad_rd <= 1'b0;
                    state <= S_READ_LATCH;
                end
                S_READ_LATCH: begin
                    state <= S_READ_HIGH;
                end
                S_READ_HIGH: begin
                    ad_rd <= 1'b1;
                    ad_cs <= 1'b1;
                    state <= S_DONE;
                end
                S_DONE: begin
                    sample_valid <= 1'b1;
                    sample_data_out <= ad_data_in;
                    state <= S_WAIT_TRIG;
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end
    
endmodule
