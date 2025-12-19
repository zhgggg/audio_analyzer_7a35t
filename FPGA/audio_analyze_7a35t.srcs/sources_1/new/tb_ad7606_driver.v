`timescale 1ns / 1ps

module tb_ad7606_driver();

    
    
    
    parameter CLK_FREQ    = 1_000_000;  
    parameter SAMPLE_RATE = 10_000;     
    parameter CLK_PERIOD  = 10;       
    
    
    
    
    reg         clk;
    reg         rst_n;
    
    
    reg         ad_busy;
    reg  [15:0] ad_data_in;
    wire        ad_cs;
    wire        ad_rd;
    wire        ad_reset;
    wire        ad_convst;
    
    
    wire        sample_valid;
    wire [15:0] sample_data_out;
    
    
    integer     sample_count;
    reg  [15:0] test_data_queue [0:9];  
    integer     data_index;
    
    
    
    
    ad7606_driver #(
        .CLK_FREQ(CLK_FREQ),
        .SAMPLE_RATE(SAMPLE_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .ad_busy(ad_busy),
        .ad_data_in(ad_data_in),
        .ad_cs(ad_cs),
        .ad_rd(ad_rd),
        .ad_reset(ad_reset),
        .ad_convst(ad_convst),
        .sample_valid(sample_valid),
        .sample_data_out(sample_data_out)
    );
    
    
    
    
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    
    
    
    
    reg convst_prev;
    reg [7:0] busy_timer;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            convst_prev <= 1'b1;
            ad_busy <= 1'b0;
            busy_timer <= 0;
        end else begin
            convst_prev <= ad_convst;
            
            
            if (ad_convst && !convst_prev) begin
                ad_busy <= 1'b1;
                busy_timer <= 0;
            end
            
            
            if (ad_busy) begin
                busy_timer <= busy_timer + 1;
                if (busy_timer >= 8) begin
                    ad_busy <= 1'b0;
                end
            end
        end
    end
    
    
    always @(*) begin
        if (sample_valid) begin
            ad_data_in = test_data_queue[data_index];
        end else begin
            ad_data_in = 16'h0000;
        end
    end
    
    
    
    
    initial begin
        
        rst_n = 0;
        sample_count = 0;
        data_index = 0;
        
        
        test_data_queue[0] = 16'h1234;
        test_data_queue[1] = 16'h5678;
        test_data_queue[2] = 16'hABCD;
        test_data_queue[3] = 16'hEF00;
        test_data_queue[4] = 16'h0001;
        test_data_queue[5] = 16'h7FFF;  
        test_data_queue[6] = 16'h8000;  
        test_data_queue[7] = 16'hFFFF;  
        test_data_queue[8] = 16'h0000;  
        test_data_queue[9] = 16'hA5A5;  
        
        $display("========================================");
        $display("AD7606 Driver Testbench - Simplified");
        $display("CLK_FREQ = %0d Hz", CLK_FREQ);
        $display("SAMPLE_RATE = %0d Hz", SAMPLE_RATE);
        $display("========================================\n");
        
        
        #(CLK_PERIOD * 10);
        rst_n = 1;
        $display("[%0t] Reset released", $time);
        
        
        @(negedge ad_reset);
        $display("[%0t] AD7606 reset completed\n", $time);
        
        
        repeat(10) begin
            
            @(posedge sample_valid);
            
            $display("[%0t] Sample #%0d:", $time, sample_count);
            $display("  Expected: 0x%04h (%0d)", test_data_queue[data_index], $signed(test_data_queue[data_index]));
            $display("  Got:      0x%04h (%0d)", sample_data_out, $signed(sample_data_out));
            
            
            if (sample_data_out === test_data_queue[data_index]) begin
                $display("  Status:   PASS ✓\n");
            end else begin
                $display("  Status:   FAIL ✗\n");
            end
            
            sample_count = sample_count + 1;
            data_index = data_index + 1;
        end
        
        
        #(CLK_PERIOD * 100);
        $display("========================================");
        $display("Simulation completed!");
        $display("Total samples: %0d", sample_count);
        $display("========================================");
        $finish;
    end
    
    
    
    
    initial begin
        #200_000_000;  
        $display("\nERROR: Simulation timeout!");
        $finish;
    end
    
    
    
    
    initial begin
        $dumpfile("tb_ad7606_driver.vcd");
        $dumpvars(0, tb_ad7606_driver);
    end
    
endmodule
