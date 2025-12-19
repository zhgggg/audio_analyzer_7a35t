`timescale 1ns / 1ps

module tb_fft_sys();

    reg aclk;
    reg aresetn;

    design_1_wrapper u_dut (
        .aclk(aclk),
         .aresetn(aresetn)
    );

    initial begin
        aresetn = 0;
        #20;
        aresetn = 1;
        aclk = 0;
        forever #10 aclk = ~aclk;
    end

    initial begin
        #50000;
        $stop;
    end

endmodule