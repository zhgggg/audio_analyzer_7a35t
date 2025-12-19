module auto_nrst (
    input  wire        sys_clk,      
    input  wire        sys_rst_n,    
    output reg         aresetn_out   
);

    
    
    
    
    
    
    parameter CNT_MAX = 25'd49_999_999;
    
    
    
    parameter RESET_WIDTH = 25'd1000;

    
    reg [24:0] cnt;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt         <= 25'd0;
            aresetn_out <= 1'b0;    
        end
        else begin
            
            
            
            if (cnt == CNT_MAX) 
                cnt <= 25'd0;
            else 
                cnt <= cnt + 1'b1;

            
            
            
            
            
            if (cnt < RESET_WIDTH) 
                aresetn_out <= 1'b0; 
            else 
                aresetn_out <= 1'b1; 
        end
    end

endmodule