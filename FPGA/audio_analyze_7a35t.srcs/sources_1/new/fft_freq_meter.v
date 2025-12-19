module fft_freq_meter #(
    parameter SAMPLE_RATE_HZ = 48_000 
)(
    input  wire          clk,
    input  wire          rst_n,
    
    
    input  wire [1:0]    sw_points,    
    input  wire          cfg_rst,      
    
    
    input  wire          fft_valid,      
    input  wire [31:0]   fft_data,       
    
    
    output reg [31:0]    freq_out, 
    output reg           measure_done  
);

    
    
    
    localparam PHYSICAL_POINTS = 4096;
    localparam PHYSICAL_SHIFT  = 12; 

    
    
    
    reg [12:0] idx_mask; 
    always @(*) begin
        case(sw_points)
            2'b00: idx_mask = 13'h1FF8; 
            2'b01: idx_mask = 13'h1FFC; 
            2'b10: idx_mask = 13'h1FFE; 
            2'b11: idx_mask = 13'h1FFF; 
        endcase
    end

    
    
    
    wire signed [15:0] data_real = fft_data[15:0];
    wire signed [15:0] data_imag = fft_data[31:16];

    reg [31:0] mag_sq;
    reg        mag_valid; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mag_sq    <= 0;
            mag_valid <= 0;
        end else begin
            
            if (fft_valid) begin
                mag_sq    <= (data_real * data_real) + (data_imag * data_imag);
                mag_valid <= 1'b1; 
            end else begin
                mag_valid <= 1'b0;
            end
        end
    end

    
    
    
    localparam STATE_WAIT_GAP   = 3'd0; 
    localparam STATE_WAIT_START = 3'd1; 
    localparam STATE_COLLECT    = 3'd2; 
    localparam STATE_DONE       = 3'd3; 

    reg [2:0]  state;
    reg [12:0] cnt;          
    reg [12:0] peak_idx;     
    reg [31:0] max_mag_sq;
    reg [63:0] calc_temp; 
    reg [12:0] fake_idx;
    
    
    reg [25:0] refresh_cnt; 
    localparam REFRESH_DELAY = 25_000_000; 
    
    
    
    localparam NOISE_THRESHOLD = 32'd10000; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= STATE_WAIT_GAP;
            cnt          <= 0;
            peak_idx     <= 0;
            max_mag_sq   <= 0;
            freq_out     <= 0;
            measure_done <= 0;
            refresh_cnt  <= 0;
        end else begin
            if (cfg_rst) begin
                state        <= STATE_WAIT_GAP;
                measure_done <= 0;
                refresh_cnt  <= 0;
                freq_out     <= 0; 
            end else begin
                case (state)
                    
                    
                    
                    STATE_WAIT_GAP: begin
                        measure_done <= 1'b0;
                        if (fft_valid == 1'b0) begin
                            state <= STATE_WAIT_START;
                        end
                    end

                    
                    
                    STATE_WAIT_START: begin
                        if (fft_valid == 1'b1) begin
                            state      <= STATE_COLLECT;
                            cnt        <= 0;          
                            peak_idx   <= 0;
                            max_mag_sq <= 0; 
                        end
                    end

                    
                    
                    STATE_COLLECT: begin
                        if (mag_valid) begin 
                            
                            
                            if (cnt > 0 && cnt < (PHYSICAL_POINTS >> 1)) begin 
                                if (mag_sq > max_mag_sq) begin
                                    max_mag_sq <= mag_sq;
                                    peak_idx   <= cnt;
                                end
                            end

                            
                            if (cnt == PHYSICAL_POINTS - 1) begin
                                
                                
                                if (max_mag_sq > NOISE_THRESHOLD) begin
                                    
                                    fake_idx = peak_idx & idx_mask;
                                    
                                    calc_temp = fake_idx * SAMPLE_RATE_HZ * 1000;
                                    freq_out  <= calc_temp >> PHYSICAL_SHIFT;
                                end
                                
                                measure_done <= 1'b1;
                                state        <= STATE_DONE;
                            end 
                            
                            cnt <= cnt + 1;
                        end
                    end

                    
                    STATE_DONE: begin
                        measure_done <= 1'b1; 
                        if (refresh_cnt >= REFRESH_DELAY) begin
                            refresh_cnt  <= 0;
                            measure_done <= 1'b0; 
                            
                            state        <= STATE_WAIT_GAP; 
                        end else begin
                            refresh_cnt <= refresh_cnt + 1;
                        end
                    end
                endcase
            end
        end
    end

endmodule