module digital_agc (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        agc_enable,   
    
    input  wire [15:0] adc_data_in,  
    output reg  [15:0] adc_data_out, 
    
    
    
    output reg  [3:0]  current_gain, 
    
    
    
    
    output wire [7:0]  gain_uart_byte 
);

    
    
    
    wire [15:0] abs_data;
    
    assign abs_data = adc_data_in[15] ? (~adc_data_in + 1'b1) : adc_data_in;

    
    
    
    
    
    localparam UPDATE_PERIOD = 10_000_000; 
    reg [23:0] timer_cnt;
    
    reg [15:0] max_peak;        
    reg [2:0]  shift_bits;      

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_cnt    <= 0;
            max_peak     <= 0;
            shift_bits   <= 0;
            current_gain <= 1;
        end else begin
            
            if (abs_data > max_peak) begin
                max_peak <= abs_data;
            end

            
            if (timer_cnt >= UPDATE_PERIOD) begin
                timer_cnt <= 0;
                
                if (agc_enable) begin
                    
                    
                    if (max_peak < 16'd2000) begin
                        
                        shift_bits   <= 3;
                        current_gain <= 8;
                    end else if (max_peak < 16'd4000) begin
                        
                        shift_bits   <= 2;
                        current_gain <= 4;
                    end else if (max_peak < 16'd10000) begin
                        
                        shift_bits   <= 1;
                        current_gain <= 2;
                    end else begin
                        
                        shift_bits   <= 0;
                        current_gain <= 1;
                    end
                end else begin
                    
                    shift_bits   <= 0;
                    current_gain <= 1;
                end
                
                
                max_peak <= 0;
                
            end else begin
                timer_cnt <= timer_cnt + 1'b1;
            end
        end
    end

    
    
    
    reg signed [19:0] expanded_data; 
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adc_data_out  <= 0;
            expanded_data <= 0;
        end else begin
            
            expanded_data <= $signed(adc_data_in) <<< shift_bits;
            
            
            
            if (expanded_data > 32767) begin
                adc_data_out <= 32767;
            end else if (expanded_data < -32768) begin
                adc_data_out <= -32768;
            end else begin
                adc_data_out <= expanded_data[15:0];
            end
        end
    end

    
    
    
    
    assign gain_uart_byte = {4'd0, current_gain};

endmodule