`timescale 1ns / 1ps

module freq_to_uart #(
    parameter CLK_FREQ  = 50000000, 
    parameter BAUD_RATE = 115200    
)(
    input  wire         clk,        
    input  wire         rst_n,      
    input  wire [31:0]  data_in,    
    output wire         uart_tx     
);

    
    
    
    localparam SEND_INTERVAL = CLK_FREQ / 2; 
    
    
    localparam S_IDLE   = 4'd0;
    localparam S_DIGIT5 = 4'd1; 
    localparam S_DIGIT4 = 4'd2;
    localparam S_DIGIT3 = 4'd3;
    localparam S_DIGIT2 = 4'd4;
    localparam S_DIGIT1 = 4'd5;
    localparam S_DIGIT0 = 4'd6; 
    localparam S_ENTER  = 4'd7; 
    localparam S_NEWLINE= 4'd8; 

    
    
    
    reg [31:0] data_latched;
    reg        latch_en; 
    wire [19:0] trunc_data;

    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) data_latched <= 0;
        else if(latch_en) data_latched <= data_in;
    end

    assign trunc_data = data_latched % 1000000; 

    reg [3:0] d5, d4, d3, d2, d1, d0;
    always @(*) begin
        d0 = trunc_data % 10;
        d1 = (trunc_data / 10) % 10;
        d2 = (trunc_data / 100) % 10;
        d3 = (trunc_data / 1000) % 10;
        d4 = (trunc_data / 10000) % 10;
        d5 = (trunc_data / 100000) % 10;
    end

    
    
    
    reg [31:0] timer_cnt;
    wire       time_to_send;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) timer_cnt <= 0;
        else if(timer_cnt >= SEND_INTERVAL - 1) timer_cnt <= 0;
        else timer_cnt <= timer_cnt + 1;
    end
    assign time_to_send = (timer_cnt == SEND_INTERVAL - 1);

    
    
    
    reg [3:0]  state;
    reg [7:0]  tx_data;      
    reg        tx_start;     
    wire       tx_busy;      
    
    
    uart_byte_tx_internal #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_tx_driver (
        .clk        (clk),
        .rst_n      (rst_n),
        .data_byte  (tx_data),
        .send_en    (tx_start),
        .uart_tx    (uart_tx),
        .busy       (tx_busy)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            tx_start <= 0;
            latch_en <= 0;
            tx_data <= 0;
        end else begin
            tx_start <= 0;
            latch_en <= 0;
            
            case (state)
                S_IDLE: begin
                    if (time_to_send) begin
                        latch_en <= 1; 
                        state <= S_DIGIT5;
                    end
                end
                S_DIGIT5: if (!tx_busy) begin tx_data <= {4'h3, d5}; tx_start <= 1; state <= S_DIGIT4; end
                S_DIGIT4: if (!tx_busy) begin tx_data <= {4'h3, d4}; tx_start <= 1; state <= S_DIGIT3; end
                S_DIGIT3: if (!tx_busy) begin tx_data <= {4'h3, d3}; tx_start <= 1; state <= S_DIGIT2; end
                S_DIGIT2: if (!tx_busy) begin tx_data <= {4'h3, d2}; tx_start <= 1; state <= S_DIGIT1; end
                S_DIGIT1: if (!tx_busy) begin tx_data <= {4'h3, d1}; tx_start <= 1; state <= S_DIGIT0; end
                S_DIGIT0: if (!tx_busy) begin tx_data <= {4'h3, d0}; tx_start <= 1; state <= S_ENTER;  end
                S_ENTER:  if (!tx_busy) begin tx_data <= 8'h0D;      tx_start <= 1; state <= S_NEWLINE; end 
                S_NEWLINE:if (!tx_busy) begin tx_data <= 8'h0A;      tx_start <= 1; state <= S_IDLE;    end 
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule


module uart_byte_tx_internal #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_byte, 
    input  wire       send_en,   
    output reg        uart_tx,   
    output reg        busy       
);
    localparam BAUD_CNT_MAX = CLK_FREQ / BAUD_RATE;
    reg [31:0] baud_cnt; 
    reg [3:0]  bit_cnt;
    reg [8:0]  shift_reg; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_tx   <= 1'b1; 
            busy      <= 1'b0;
            bit_cnt   <= 0;
            baud_cnt  <= 0;
            shift_reg <= 0;
        end else begin
            if (send_en && !busy) begin
                busy      <= 1'b1;
                uart_tx   <= 1'b0; 
                shift_reg <= {1'b1, data_byte}; 
                bit_cnt   <= 0;
                baud_cnt  <= 0;
            end else if (busy) begin
                if (baud_cnt >= BAUD_CNT_MAX - 1) begin
                    baud_cnt <= 0;
                    if (bit_cnt == 9) begin 
                        busy    <= 1'b0;
                        uart_tx <= 1'b1; 
                    end else begin
                        uart_tx   <= shift_reg[0]; 
                        shift_reg <= {1'b1, shift_reg[8:1]};
                        bit_cnt   <= bit_cnt + 1;
                    end
                end else begin
                    baud_cnt <= baud_cnt + 1;
                end
            end
        end
    end
endmodule