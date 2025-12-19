`timescale 1ns / 1ps

module tlast_gen #(
    parameter DATA_WIDTH = 16,
    parameter PKT_LENGTH = 1024
)(
    input  wire                   aclk,
    input  wire                   aresetn,

    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire                   s_axis_tvalid,
    output wire                   s_axis_tready,

    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire                   m_axis_tvalid,
    output wire                   m_axis_tlast,
    input  wire                   m_axis_tready
);

    reg [$clog2(PKT_LENGTH)-1:0] cnt;

    wire axis_handshake;
    assign axis_handshake = s_axis_tvalid & m_axis_tready;

    assign m_axis_tdata  = s_axis_tdata;
    assign m_axis_tvalid = s_axis_tvalid;
    assign s_axis_tready = m_axis_tready;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            cnt <= 0;
        end
        else if (axis_handshake) begin
            if (cnt == PKT_LENGTH - 1) begin
                cnt <= 0;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

    assign m_axis_tlast = (cnt == PKT_LENGTH - 1) && axis_handshake;

endmodule