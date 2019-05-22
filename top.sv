module top(
    input wire CLOCK_50,
    input wire CPU_RESET_n, 
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [9:0] LEDR
);

wire nreset = CPU_RESET_n;
wire slow_clock;

// Takes in 50MHz clock and outputs 5.96Hz clock.
clock_divider #(
.COUNTER_SIZE (23)
) clk_50MHz_to_6Hz (
.fast_clock(CLOCK_50), 
.slow_clock(slow_clock)
);

seven_segment HEX0_display(
.clock(slow_clock),
.nreset(nreset),
.dec(dec0),
.hex(HEX0)
);
seven_segment HEX1_display(
.clock(slow_clock),
.nreset(nreset),
.dec(dec1),
.hex(HEX1)
);
seven_segment HEX2_display(
.clock(slow_clock),
.nreset(nreset),
.dec(dec2),
.hex(HEX2)
);
seven_segment HEX3_display(
.clock(slow_clock),
.nreset(nreset),
.dec(dec3),
.hex(HEX3)
);

reg [3:0] count_hex;
reg [3:0] count_led;
reg [3:0] dec0;
reg [3:0] dec1;
reg [3:0] dec2;
reg [3:0] dec3;
always @ (posedge slow_clock)
begin
    if (!nreset)
    begin
        dec0 <= 4'd0;
        dec1 <= 4'd0;
        dec2 <= 4'd0;
        dec3 <= 4'd0;
        count_hex <= 4'd0;
        count_led <= 4'd0;
    end
    else
    begin
        dec0  <= count_hex;
        dec1  <= count_hex;
        dec2  <= count_hex;
        dec3  <= count_hex;
        count_hex <= count_hex + 4'd1;
        if (count_led < 4'd9)
            count_led <= count_led + 4'd1;
        else
            count_led <= 4'd0;
    end
end

assign LEDR[9:0] = 1'b1 << count_led;

endmodule

//************************************************************************************************//
// Seven segment display control
//************************************************************************************************//
module seven_segment(
    input clock,
    input nreset,
    input wire [3:0] dec,
    output wire [6:0] hex
);

// Seven segment display LEDs are active low
assign hex = ~nhex;

reg [6:0] nhex;
always @ (posedge clock)
begin
    if (!nreset)
    begin
        nhex <= 7'b1000000;
    end
    else
    begin
        case (dec)
            4'h0 : nhex <= 7'b0111111;
            4'h1 : nhex <= 7'b0000110;
            4'h2 : nhex <= 7'b1011011;
            4'h3 : nhex <= 7'b1001111;
            4'h4 : nhex <= 7'b1100110;
            4'h5 : nhex <= 7'b1101101;
            4'h6 : nhex <= 7'b1111101;
            4'h7 : nhex <= 7'b0000111;
            4'h8 : nhex <= 7'b1111111;
            4'h9 : nhex <= 7'b1101111;
            4'ha : nhex <= 7'b1110111;
            4'hb : nhex <= 7'b1111100;
            4'hc : nhex <= 7'b0111001;
            4'hd : nhex <= 7'b1011110;
            4'he : nhex <= 7'b1111001;
            4'hf : nhex <= 7'b1110001;
            default : 
            begin
                nhex <= 7'b1001001;
                $display("WARNING: Invalid case.");
            end
        endcase
    end
end

endmodule

//************************************************************************************************//
// Clock Divider
//************************************************************************************************//
// Module clock_divider returns a slower clock given by the following formula:
// f_COUT = f_CIN / 2^N
module clock_divider #(
parameter COUNTER_SIZE = 23
)
(
input fast_clock,
output slow_clock
);
// 2^COUNTER_SIZE times slower
parameter COUNTER_MAX_COUNT = (2 ** COUNTER_SIZE) - 1;

reg [COUNTER_SIZE-1:0] count;

/* synthesis translate_off */
initial begin
    count <= 0;
end
/* synthesis translate_on */

always @ (posedge fast_clock)
begin
    if(count >= COUNTER_MAX_COUNT)
        count <= 0;
    else
        count <= count + 1;
end

assign slow_clock = count[COUNTER_SIZE-1];

endmodule
