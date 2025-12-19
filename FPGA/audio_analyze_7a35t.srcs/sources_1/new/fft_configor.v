`timescale 1ns / 1ps

module fft_sys_controller(
    input wire clk,             
    input wire rst_n,           
    input wire [1:0] sw_points, 
    
    
    
    output reg [15:0] m_axis_config_tdata,
    output reg        m_axis_config_tvalid,
    input  wire       m_axis_config_tready,
    
    
    output reg [12:0] o_frame_len, 
    
    
    
    output wire       o_force_rst 
    );

    
    
    
    
    localparam NFFT_512  = 5'b01001; 
    localparam NFFT_1024 = 5'b01010; 
    localparam NFFT_2048 = 5'b01011; 
    localparam NFFT_4096 = 5'b01100; 
    
    localparam CMD_FFT = 1'b1; 

    
    
    
    reg [1:0] sw_sync_0, sw_sync_1;
    reg [1:0] sw_stable;
    reg [19:0] debounce_cnt;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sw_sync_0 <= 2'b00;
            sw_sync_1 <= 2'b00;
            sw_stable <= 2'b00;
            debounce_cnt <= 0;
        end else begin
            sw_sync_0 <= sw_points;
            sw_sync_1 <= sw_sync_0;
            
            if (sw_sync_1 != sw_stable) begin
                
                if (debounce_cnt == 20'd500_000) begin 
                    sw_stable <= sw_sync_1;
                    debounce_cnt <= 0;
                end else begin
                    debounce_cnt <= debounce_cnt + 1;
                end
            end else begin
                debounce_cnt <= 0;
            end
        end
    end

    
    
    
    localparam S_WAIT_STABLE = 0; 
    localparam S_INIT_SEND   = 1; 
    localparam S_IDLE        = 2; 
    localparam S_SEND_CFG    = 3; 
    localparam S_WAIT_READY  = 4; 

    reg [2:0] state;
    reg [1:0] last_sw_stable;
    reg [4:0] target_nfft;
    
    
    assign o_force_rst = (state != S_IDLE);

    
    task set_params;
        input [1:0] sw;
        begin
            case(sw)
                2'b00: begin target_nfft <= NFFT_512;  o_frame_len <= 13'd512;  end
                2'b01: begin target_nfft <= NFFT_1024; o_frame_len <= 13'd1024; end
                2'b10: begin target_nfft <= NFFT_2048; o_frame_len <= 13'd2048; end
                2'b11: begin target_nfft <= NFFT_4096; o_frame_len <= 13'd4096; end
            endcase
        end
    endtask

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= S_WAIT_STABLE; 
            m_axis_config_tvalid <= 0;
            m_axis_config_tdata  <= 0;
            last_sw_stable <= 2'b00;
            o_frame_len <= 13'd4096; 
            target_nfft <= NFFT_4096;
        end else begin
            
            case(state)
                
                
                S_WAIT_STABLE: begin
                    
                    
                    
                    
                    
                    if (debounce_cnt == 20'd400_000) begin
                        state <= S_INIT_SEND;
                    end
                end

                
                S_INIT_SEND: begin
                    set_params(sw_stable);      
                    last_sw_stable <= sw_stable;
                    state <= S_SEND_CFG;        
                end

                
                S_IDLE: begin
                    if (sw_stable != last_sw_stable) begin
                        set_params(sw_stable);
                        last_sw_stable <= sw_stable;
                        state <= S_SEND_CFG; 
                    end
                end

                
                S_SEND_CFG: begin
                    
                    
                    m_axis_config_tdata <= {7'b0, CMD_FFT, 3'b0, target_nfft}; 
                    m_axis_config_tvalid <= 1;
                    
                    if (m_axis_config_tready) begin
                        m_axis_config_tvalid <= 0;
                        state <= S_IDLE; 
                    end else begin
                        state <= S_WAIT_READY;
                    end
                end

                
                S_WAIT_READY: begin
                    if (m_axis_config_tready) begin
                        m_axis_config_tvalid <= 0;
                        state <= S_IDLE;
                    end
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule