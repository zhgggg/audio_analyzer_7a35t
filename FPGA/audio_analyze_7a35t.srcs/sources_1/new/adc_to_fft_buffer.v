`timescale 1ns / 1ps

module adc_to_fft_buffer #(
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 8192 
)(
    input wire                   aclk,    
    input wire                   aresetn, 
    input wire                   cfg_rst, 
    input wire [12:0]            frame_length, 
    input wire [DATA_WIDTH-1:0]  adc_data, 
    input wire                   adc_valid,
    output reg [DATA_WIDTH-1:0]  m_axis_tdata,
    output reg                   m_axis_tvalid,
    output reg                   m_axis_tlast, 
    input  wire                  m_axis_tready 
);

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    reg [12:0] wr_ptr; 
    reg [12:0] rd_ptr; 
    wire [12:0] data_count = wr_ptr - rd_ptr;

    always @(posedge aclk) begin
        if (!aresetn || cfg_rst) begin
            wr_ptr <= 0;
        end else if (adc_valid) begin
            mem[wr_ptr] <= adc_data;
            wr_ptr      <= wr_ptr + 1'b1;
        end
    end

    reg [1:0] state;
    localparam IDLE    = 2'b00;
    localparam SENDING = 2'b01;
    reg [12:0] send_cnt; 

    always @(posedge aclk) begin
        if (!aresetn || cfg_rst) begin
            rd_ptr        <= 0;
            state         <= IDLE;
            m_axis_tdata  <= 0;
            m_axis_tvalid <= 0;
            m_axis_tlast  <= 0;
            send_cnt      <= 0;
        end else begin
            case (state)
                IDLE: begin
                    m_axis_tvalid <= 0;
                    m_axis_tlast  <= 0;
                    if (data_count >= frame_length && m_axis_tready) begin
                        state <= SENDING;
                        send_cnt <= 0;
                        m_axis_tdata  <= mem[rd_ptr];
                        m_axis_tvalid <= 1'b1;
                        rd_ptr        <= rd_ptr + 1'b1;
                    end
                end

                SENDING: begin
                    if (m_axis_tready) begin
                        if (send_cnt == frame_length - 1) begin
                            state         <= IDLE;
                            m_axis_tvalid <= 0; 
                            m_axis_tlast  <= 0;
                        end else begin
                            send_cnt      <= send_cnt + 1'b1;
                            m_axis_tdata  <= mem[rd_ptr]; 
                            rd_ptr        <= rd_ptr + 1'b1;
                            m_axis_tvalid <= 1'b1;
                            if (send_cnt == frame_length - 2)
                                m_axis_tlast <= 1'b1;
                            else
                                m_axis_tlast <= 0;
                        end
                    end 
                end
            endcase
        end
    end

endmodule
