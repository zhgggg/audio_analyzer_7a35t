`timescale 1ns / 1ps

module fifo_num(
    input  wire        clk,
    input  wire        rst_n,
    
    
    input  wire [31:0] i_freq_data,   
    input  wire        i_freq_valid,  
    
    
    output reg  [31:0] o_stable_freq  
);

    
    
    
    
    
    reg valid_d0, valid_d1;
    wire valid_pos_edge;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_d0 <= 1'b0;
            valid_d1 <= 1'b0;
        end else begin
            valid_d0 <= i_freq_valid;
            valid_d1 <= valid_d0;
        end
    end

    
    assign valid_pos_edge = valid_d0 & (~valid_d1);

    
    
    
    reg [31:0] last_candidate; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_stable_freq  <= 32'd0;
            last_candidate <= 32'hFFFF_FFFF; 
        end else begin
            if (valid_pos_edge) begin
                
                
                
                if (i_freq_data == last_candidate) begin
                    o_stable_freq <= i_freq_data;
                end
                
                
                last_candidate <= i_freq_data;
            end
        end
    end

endmodule