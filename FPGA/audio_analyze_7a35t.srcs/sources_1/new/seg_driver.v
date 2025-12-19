`timescale 1ns / 1ps

module seg_driver(
    input  wire          clk,       
    input  wire          rst_n,     
    input  wire [31:0]   data_in,   
    
    output reg  [5:0]    sel,       
    output reg  [7:0]    seg        
);

    
    
    
    
    
    wire [19:0] trunc_data; 
    assign trunc_data = data_in % 1000000; 

    reg [3:0] digit_0, digit_1, digit_2, digit_3, digit_4, digit_5;

    
    
    always @(*) begin
        digit_0 = trunc_data % 10;
        digit_1 = (trunc_data / 10) % 10;
        digit_2 = (trunc_data / 100) % 10;
        digit_3 = (trunc_data / 1000) % 10;
        digit_4 = (trunc_data / 10000) % 10;
        digit_5 = (trunc_data / 100000) % 10;
    end

    
    
    
    
    reg [15:0] scan_cnt;
    wire       scan_tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            scan_cnt <= 0;
        else if (scan_cnt == 50000 - 1) 
            scan_cnt <= 0;
        else 
            scan_cnt <= scan_cnt + 1;
    end

    assign scan_tick = (scan_cnt == 50000 - 1);

    
    
    
    reg [2:0] current_pos; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_pos <= 0;
        else if (scan_tick) begin
            if (current_pos == 5)
                current_pos <= 0;
            else
                current_pos <= current_pos + 1;
        end
    end

    
    
    
    
    
    reg [3:0] current_digit_val;
    always @(*) begin
        case (current_pos)
            3'd0: current_digit_val = digit_0; 
            3'd1: current_digit_val = digit_1;
            3'd2: current_digit_val = digit_2;
            3'd3: current_digit_val = digit_3;
            3'd4: current_digit_val = digit_4;
            3'd5: current_digit_val = digit_5; 
            default: current_digit_val = 4'd0;
        endcase
    end

    
    
    always @(*) begin
        case (current_digit_val)
            
            4'h0:    seg = 8'b0011_1111; 
            4'h1:    seg = 8'b0000_0110; 
            4'h2:    seg = 8'b0101_1011; 
            4'h3:    seg = 8'b0100_1111; 
            4'h4:    seg = 8'b0110_0110; 
            4'h5:    seg = 8'b0110_1101; 
            4'h6:    seg = 8'b0111_1101; 
            4'h7:    seg = 8'b0000_0111; 
            4'h8:    seg = 8'b0111_1111; 
            4'h9:    seg = 8'b0110_1111; 
            default: seg = 8'b0000_0000; 
        endcase
    end

    
    always @(*) begin
        case (current_pos)
            3'd0: sel = 6'b111110; 
            3'd1: sel = 6'b111101; 
            3'd2: sel = 6'b111011;
            3'd3: sel = 6'b110111;
            3'd4: sel = 6'b101111;
            3'd5: sel = 6'b011111; 
            default: sel = 6'b111111;
        endcase
    end

endmodule