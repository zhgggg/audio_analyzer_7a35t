`timescale 1ns / 1ps

module periodic_rst_gen #(
    
    parameter integer CLK_FREQ_HZ = 50_000_000, 
    parameter integer PERIOD_MS   = 500          
)(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
    input  wire clk,      
    
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst_n RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input  wire rst_n,    
    
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 periodic_rst_n RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    output reg  periodic_rst_n 
);

    
    
    
    
    localparam integer MAX_CNT = (CLK_FREQ_HZ / 1000) * PERIOD_MS;
    
    
    localparam integer PULSE_WIDTH_CNT = CLK_FREQ_HZ / 1000;

    reg [31:0] cnt;

    
    
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt            <= 0;
            periodic_rst_n <= 1'b1; 
        end else begin
            
            if (cnt >= MAX_CNT - 1) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end

            
            
            if (cnt < PULSE_WIDTH_CNT) begin
                periodic_rst_n <= 1'b0; 
            end else begin
                periodic_rst_n <= 1'b1; 
            end
        end
    end

endmodule