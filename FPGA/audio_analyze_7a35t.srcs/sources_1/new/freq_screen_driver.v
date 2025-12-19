`timescale 1ns / 1ps

module freq_screen_driver #(
    parameter CLK_FREQ  = 50000000, 
    parameter BAUD_RATE = 115200    
)(
    input  wire          clk,
    input  wire          rst_n,
    input  wire [31:0]   data_in,      
    
    
    input  wire          agc_enable,   
    input  wire [3:0]    current_gain, 
    
    output wire          uart_tx       
);

    
    
    
    localparam CNT_200MS   = CLK_FREQ / 5; 
    localparam CNT_REFRESH = CLK_FREQ / 2; 

    reg [31:0] main_cnt;
    reg        power_on_done;
    wire       time_to_send;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            main_cnt <= 0;
            power_on_done <= 0;
        end else begin
            if(!power_on_done) begin
                if(main_cnt >= CNT_200MS) begin
                    power_on_done <= 1;
                    main_cnt <= 0;
                end else begin
                    main_cnt <= main_cnt + 1;
                end
            end else begin
                if(main_cnt >= CNT_REFRESH - 1) main_cnt <= 0;
                else main_cnt <= main_cnt + 1;
            end
        end
    end
    
    assign time_to_send = power_on_done && (main_cnt == 0);

    
    
    
    reg [31:0] latched_freq;
    reg        latched_agc_en;
    reg [3:0]  latched_gain;
    reg        latch_en;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            latched_freq <= 0;
            latched_agc_en <= 0;
            latched_gain <= 1;
        end else if(latch_en) begin
            latched_freq <= data_in;
            latched_agc_en <= agc_enable;
            latched_gain <= current_gain;
        end
    end

    
    
    
    
    
    
    
    reg [23:0] note_str;
always @(*) begin
        
        note_str = "---"; 

        if (latched_freq < 10000) begin
            note_str = "LOW";
        end
        else if (latched_freq < 63500) begin
            note_str = "---";
        end
        
        else if (latched_freq < 126900) begin
            if      (latched_freq < 67300)  note_str = "C2 ";
            else if (latched_freq < 71300)  note_str = "C#2";
            else if (latched_freq < 75500)  note_str = "D2 ";
            else if (latched_freq < 80000)  note_str = "D#2";
            else if (latched_freq < 84800)  note_str = "E2 ";
            else if (latched_freq < 89800)  note_str = "F2 ";
            else if (latched_freq < 95100)  note_str = "F#2";
            else if (latched_freq < 100700) note_str = "G2 ";
            else if (latched_freq < 106700) note_str = "G#2";
            else if (latched_freq < 113000) note_str = "A2 ";
            else if (latched_freq < 119700) note_str = "A#2";
            else                            note_str = "B2 ";
        end
        
        else if (latched_freq < 255000) begin
            if      (latched_freq < 134500) note_str = "C3 ";
            else if (latched_freq < 142500) note_str = "C#3";
            else if (latched_freq < 151000) note_str = "D3 ";
            else if (latched_freq < 160000) note_str = "D#3";
            else if (latched_freq < 169500) note_str = "E3 ";
            else if (latched_freq < 179500) note_str = "F3 ";
            else if (latched_freq < 190200) note_str = "F#3";
            else if (latched_freq < 201500) note_str = "G3 ";
            else if (latched_freq < 213500) note_str = "G#3";
            else if (latched_freq < 226200) note_str = "A3 ";
            else if (latched_freq < 239700) note_str = "A#3";
            else                            note_str = "B3 ";
        end
        
        else if (latched_freq < 508400) begin
            if      (latched_freq < 270000) note_str = "C4 ";
            else if (latched_freq < 285300) note_str = "C#4";
            else if (latched_freq < 302300) note_str = "D4 ";
            else if (latched_freq < 320200) note_str = "D#4";
            else if (latched_freq < 339300) note_str = "E4 ";
            else if (latched_freq < 359500) note_str = "F4 ";
            else if (latched_freq < 380800) note_str = "F#4";
            else if (latched_freq < 403500) note_str = "G4 ";
            else if (latched_freq < 428000) note_str = "G#4";
            else if (latched_freq < 453000) note_str = "A4 ";
            else if (latched_freq < 480000) note_str = "A#4";
            else                            note_str = "B4 ";
        end
        
        else if (latched_freq < 1017000) begin
            if      (latched_freq < 538600) note_str = "C5 ";
            else if (latched_freq < 570600) note_str = "C#5";
            else if (latched_freq < 604500) note_str = "D5 ";
            else if (latched_freq < 640500) note_str = "D#5";
            else if (latched_freq < 678600) note_str = "E5 ";
            else if (latched_freq < 719000) note_str = "F5 ";
            else if (latched_freq < 761700) note_str = "F#5";
            else if (latched_freq < 807000) note_str = "G5 ";
            else if (latched_freq < 855000) note_str = "G#5";
            else if (latched_freq < 906000) note_str = "A5 ";
            else if (latched_freq < 960000) note_str = "A#5";
            else                            note_str = "B5 ";
        end
        
        else if (latched_freq < 2000000) begin
             note_str = "HI "; 
        end
        else begin
             note_str = "ERR"; 
        end
    end

    
    
    
    localparam S_IDLE       = 0;
    
    
    localparam S_BCD_START  = 1; 
    localparam S_BCD_SHIFT  = 2; 

    localparam S_PACKET_GAP = 3; 

    
    localparam S_CMD1_HEAD  = 4; 
    localparam S_CMD1_DATA  = 5; 
    localparam S_CMD1_TAIL  = 6; 

    
    localparam S_CMD2_HEAD  = 7; 
    localparam S_CMD2_DATA  = 8; 
    localparam S_CMD2_QUOTE = 9; 
    localparam S_CMD2_TAIL  = 10; 

    
    localparam S_CMD3_HEAD  = 11;
    localparam S_CMD3_DATA  = 12;
    localparam S_CMD3_QUOTE = 13;
    localparam S_CMD3_TAIL  = 14;

    
    localparam S_CMD4_HEAD  = 15;
    localparam S_CMD4_DATA  = 16;
    localparam S_CMD4_QUOTE = 17;
    localparam S_CMD4_TAIL  = 18;

    reg [4:0] state;
    reg [4:0] next_state_after_gap; 
    reg [3:0] byte_idx; 
    reg [7:0] tx_data;
    reg       tx_req;
    wire      tx_busy;

    localparam GAP_DELAY_CYCLES = 250_000;
    reg [19:0] gap_cnt;

    
    reg [31:0] bin_data_reg;  
    reg [31:0] bcd_data_reg;  
    reg [5:0]  shift_cnt;     
    reg [31:0] bcd_temp; 

    uart_byte_tx_internal #(
        .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)
    ) u_uart_core (
        .clk(clk), .rst_n(rst_n), .data_byte(tx_data), 
        .send_en(tx_req), .uart_tx(uart_tx), .busy(tx_busy)
    );

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= S_IDLE;
            next_state_after_gap <= S_IDLE;
            byte_idx <= 0;
            tx_req <= 0;
            latch_en <= 0;
            gap_cnt <= 0;
            bin_data_reg <= 0;
            bcd_data_reg <= 0;
            shift_cnt <= 0;
            bcd_temp <= 0;
        end else begin
            tx_req <= 0; 
            latch_en <= 0;

            case(state)
                S_IDLE: begin
                    if(time_to_send) begin
                        latch_en <= 1; 
                        state <= S_BCD_START; 
                    end
                end

                
                
                
                S_BCD_START: begin
                    
                    bin_data_reg <= latched_freq; 
                    bcd_data_reg <= 32'd0;
                    shift_cnt <= 0;
                    state <= S_BCD_SHIFT;
                end

                S_BCD_SHIFT: begin
                    if (shift_cnt < 32) begin 
                        bcd_temp = bcd_data_reg;
                        
                        if (bcd_temp[3:0]   > 4) bcd_temp[3:0]   = bcd_temp[3:0]   + 3; 
                        if (bcd_temp[7:4]   > 4) bcd_temp[7:4]   = bcd_temp[7:4]   + 3; 
                        if (bcd_temp[11:8]  > 4) bcd_temp[11:8]  = bcd_temp[11:8]  + 3; 
                        if (bcd_temp[15:12] > 4) bcd_temp[15:12] = bcd_temp[15:12] + 3; 
                        if (bcd_temp[19:16] > 4) bcd_temp[19:16] = bcd_temp[19:16] + 3; 
                        if (bcd_temp[23:20] > 4) bcd_temp[23:20] = bcd_temp[23:20] + 3; 
                        if (bcd_temp[27:24] > 4) bcd_temp[27:24] = bcd_temp[27:24] + 3; 
                        if (bcd_temp[31:28] > 4) bcd_temp[31:28] = bcd_temp[31:28] + 3; 

                        {bcd_data_reg, bin_data_reg} <= {bcd_temp, bin_data_reg} << 1;
                        shift_cnt <= shift_cnt + 1;
                    end else begin
                        state <= S_CMD1_HEAD;
                        byte_idx <= 0;
                    end
                end

                
                
                
                S_PACKET_GAP: begin
                    if (gap_cnt >= GAP_DELAY_CYCLES) begin
                        gap_cnt <= 0;
                        state <= next_state_after_gap; 
                        byte_idx <= 0;
                    end else begin
                        gap_cnt <= gap_cnt + 1;
                    end
                end

                
                
                
                S_CMD1_HEAD: begin 
                    if(!tx_busy && !tx_req) begin
                        case(byte_idx)
                            0: tx_data <= "x"; 
                            1: tx_data <= "0"; 2: tx_data <= ".";
                            3: tx_data <= "v"; 4: tx_data <= "a"; 5: tx_data <= "l";
                            6: tx_data <= "=";
                        endcase
                        tx_req <= 1;
                        if(byte_idx == 6) begin byte_idx <= 0; state <= S_CMD1_DATA; end 
                        else byte_idx <= byte_idx + 1;
                    end
                end
                S_CMD1_DATA: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_req <= 1;
                        
                        case(byte_idx)
                            0: tx_data <= {4'h3, bcd_data_reg[31:28]}; 
                            1: tx_data <= {4'h3, bcd_data_reg[27:24]}; 
                            2: tx_data <= {4'h3, bcd_data_reg[23:20]};  
                            3: tx_data <= {4'h3, bcd_data_reg[19:16]}; 
                            4: tx_data <= {4'h3, bcd_data_reg[15:12]}; 
                            5: tx_data <= {4'h3, bcd_data_reg[11:8]};  
                            6: tx_data <= {4'h3, bcd_data_reg[7:4]};   
                            7: tx_data <= {4'h3, bcd_data_reg[3:0]};   
                        endcase
                        if(byte_idx == 7) begin byte_idx <= 0; state <= S_CMD1_TAIL; end 
                        else byte_idx <= byte_idx + 1;
                    end
                end
                S_CMD1_TAIL: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_data <= 8'hFF; tx_req <= 1;
                        if(byte_idx == 2) begin 
                            byte_idx <= 0; 
                            next_state_after_gap <= S_CMD2_HEAD; 
                            state <= S_PACKET_GAP; 
                        end else byte_idx <= byte_idx + 1;
                    end
                end

                
                
                
                S_CMD2_HEAD: begin 
                    if(!tx_busy && !tx_req) begin
                        case(byte_idx)
                            0: tx_data <= "t"; 1: tx_data <= "4"; 2: tx_data <= ".";
                            3: tx_data <= "t"; 4: tx_data <= "x"; 5: tx_data <= "t";
                            6: tx_data <= "="; 7: tx_data <= "\"";
                        endcase
                        tx_req <= 1;
                        if(byte_idx == 7) begin byte_idx <= 0; state <= S_CMD2_DATA; end 
                        else byte_idx <= byte_idx + 1;
                    end
                end
                S_CMD2_DATA: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_req <= 1;
                        case(byte_idx)
                            0: tx_data <= note_str[23:16]; 
                            1: tx_data <= note_str[15:8];  
                            2: tx_data <= note_str[7:0];   
                        endcase
                        if(byte_idx == 2) begin byte_idx <= 0; state <= S_CMD2_QUOTE; end 
                        else byte_idx <= byte_idx + 1;
                    end
                end
                S_CMD2_QUOTE: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_data <= "\""; tx_req <= 1; state <= S_CMD2_TAIL;
                    end
                end
                S_CMD2_TAIL: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_data <= 8'hFF; tx_req <= 1;
                        if(byte_idx == 2) begin 
                            byte_idx <= 0; 
                            next_state_after_gap <= S_CMD3_HEAD; 
                            state <= S_PACKET_GAP; 
                        end else byte_idx <= byte_idx + 1;
                    end
                end

                
                
                
                S_CMD3_HEAD: begin 
                    if(!tx_busy && !tx_req) begin
                        case(byte_idx)
                            0: tx_data <= "t"; 1: tx_data <= "7"; 2: tx_data <= ".";
                            3: tx_data <= "t"; 4: tx_data <= "x"; 5: tx_data <= "t";
                            6: tx_data <= "="; 7: tx_data <= "\"";
                        endcase
                        tx_req <= 1;
                        if(byte_idx == 7) begin byte_idx <= 0; state <= S_CMD3_DATA; end 
                        else byte_idx <= byte_idx + 1;
                    end
                end
                S_CMD3_DATA: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_req <= 1;
                        if (latched_agc_en) begin
                            
                            case(byte_idx)
                                0: tx_data <= 8'hE5; 1: tx_data <= 8'hBC; 2: tx_data <= 8'h80;
                                3: tx_data <= 8'hE5; 4: tx_data <= 8'h90; 5: tx_data <= 8'hAF;
                            endcase
                        end else begin
                            
                            case(byte_idx)
                                0: tx_data <= 8'hE5; 1: tx_data <= 8'h85; 2: tx_data <= 8'hB3;
                                3: tx_data <= 8'hE9; 4: tx_data <= 8'h97; 5: tx_data <= 8'hAD;
                            endcase
                        end
                        if(byte_idx == 5) begin byte_idx <= 0; state <= S_CMD3_QUOTE; end 
                        else byte_idx <= byte_idx + 1;
                    end
                end
                S_CMD3_QUOTE: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_data <= "\""; tx_req <= 1; state <= S_CMD3_TAIL;
                    end
                end
                S_CMD3_TAIL: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_data <= 8'hFF; tx_req <= 1;
                        if(byte_idx == 2) begin 
                            byte_idx <= 0; 
                            next_state_after_gap <= S_CMD4_HEAD; 
                            state <= S_PACKET_GAP; 
                        end else byte_idx <= byte_idx + 1;
                    end
                end

                
                
                
                S_CMD4_HEAD: begin 
                    if(!tx_busy && !tx_req) begin
                        case(byte_idx)
                            0: tx_data <= "t"; 1: tx_data <= "9"; 2: tx_data <= ".";
                            3: tx_data <= "t"; 4: tx_data <= "x"; 5: tx_data <= "t";
                            6: tx_data <= "="; 7: tx_data <= "\"";
                        endcase
                        tx_req <= 1;
                        if(byte_idx == 7) begin byte_idx <= 0; state <= S_CMD4_DATA; end 
                        else byte_idx <= byte_idx + 1;
                    end
                end
                S_CMD4_DATA: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_req <= 1;
                        case(byte_idx)
                            0: tx_data <= {4'h3, latched_gain}; 
                            1: tx_data <= "x";
                            2: tx_data <= " ";
                        endcase
                        if(byte_idx == 2) begin byte_idx <= 0; state <= S_CMD4_QUOTE; end 
                        else byte_idx <= byte_idx + 1;
                    end
                end
                S_CMD4_QUOTE: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_data <= "\""; tx_req <= 1; state <= S_CMD4_TAIL;
                    end
                end
                S_CMD4_TAIL: begin 
                    if(!tx_busy && !tx_req) begin
                        tx_data <= 8'hFF; tx_req <= 1;
                        if(byte_idx == 2) begin 
                            byte_idx <= 0; 
                            next_state_after_gap <= S_IDLE; 
                            state <= S_PACKET_GAP; 
                        end else byte_idx <= byte_idx + 1;
                    end
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule