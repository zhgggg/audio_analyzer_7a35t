`timescale 1ns / 1ps

module fft_freq_analyzer #(
    parameter SAMPLE_RATE = 48000,  
    parameter MAX_FFT_POINTS = 2048
)(
    input wire        clk,
    input wire        rst_n,
    
    
    input wire [31:0] fft_result_real,  
    input wire [31:0] fft_result_imag,  
    input wire        fft_result_valid,
    input wire        fft_result_last,
    input wire [11:0] fft_points,       
    
    
    output reg [15:0] peak_freq_hz,     
    output reg [31:0] peak_magnitude,   
    output reg [11:0] peak_bin,         
    output reg        analysis_done     
);

    
    
    
    
    reg [15:0] abs_real, abs_imag;
    reg [31:0] magnitude;
    reg [11:0] bin_counter;
    
    reg [31:0] max_magnitude;
    reg [11:0] max_bin;
    
    
    localparam IDLE        = 2'd0;
    localparam PROCESSING  = 2'd1;
    localparam CALC_FREQ   = 2'd2;
    localparam DONE        = 2'd3;
    
    reg [1:0] state;
    
    
    always @(*) begin
        abs_real = fft_result_real[15] ? (~fft_result_real[15:0] + 1) : fft_result_real[15:0];
        abs_imag = fft_result_imag[15] ? (~fft_result_imag[15:0] + 1) : fft_result_imag[15:0];
    end
    
    
    always @(*) begin
        if (abs_real > abs_imag)
            magnitude = abs_real + (abs_imag >> 1);
        else
            magnitude = abs_imag + (abs_real >> 1);
    end
    
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bin_counter <= 0;
            max_magnitude <= 0;
            max_bin <= 0;
            peak_freq_hz <= 0;
            peak_magnitude <= 0;
            peak_bin <= 0;
            analysis_done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    analysis_done <= 0;
                    max_magnitude <= 0;
                    max_bin <= 0;
                    bin_counter <= 0;
                    if (fft_result_valid) begin
                        state <= PROCESSING;
                    end
                end
                
                PROCESSING: begin
                    if (fft_result_valid) begin
                        
                        if (bin_counter > 0 && bin_counter < (fft_points >> 1)) begin
                            if (magnitude > max_magnitude) begin
                                max_magnitude <= magnitude;
                                max_bin <= bin_counter;
                            end
                        end
                        
                        bin_counter <= bin_counter + 1;
                        
                        if (fft_result_last) begin
                            state <= CALC_FREQ;
                        end
                    end
                end
                
                CALC_FREQ: begin
                    
                    
                    
                    
                    peak_magnitude <= max_magnitude;
                    peak_bin <= max_bin;
                    
                    
                    
                    case (fft_points)
                        12'd256:  peak_freq_hz <= (max_bin * 48000) / 256;   
                        12'd512:  peak_freq_hz <= (max_bin * 48000) / 512;   
                        12'd1024: peak_freq_hz <= (max_bin * 48000) / 1024;  
                        12'd2048: peak_freq_hz <= (max_bin * 48000) / 2048;  
                        default:  peak_freq_hz <= (max_bin * 48000) / 1024;
                    endcase
                    
                    state <= DONE;
                end
                
                DONE: begin
                    analysis_done <= 1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
