`timescale 1ns / 1ps

module tb_auto_nrst();

    reg clk;
    reg rst_n;
    wire pulse_out;

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    auto_nrst #(
        .CNT_MAX(99) 
    ) u_pulse_gen_0p5s (
        .clk(clk),
        .rst_n(rst_n),
        .pulse_out(pulse_out)
    );

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        #5000; 
        $stop;
    end

endmodule
