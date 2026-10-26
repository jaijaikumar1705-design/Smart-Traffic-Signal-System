`timescale 1ns / 1ps
//==============================================================
// Module      : time_allocator
// Description : Converts a 2-bit density level into a green-light
//               duration (in seconds) to be loaded into the timer.
//==============================================================
module time_allocator #(
    parameter TIME_WIDTH = 8
)(
    input  wire                    clk,
    input  wire                    rst,
    input  wire [1:0]              density,
    output reg  [TIME_WIDTH-1:0]   green_time
);

    // Green-time table (seconds) per density level
    localparam [TIME_WIDTH-1:0] T_LOW       = 10;
    localparam [TIME_WIDTH-1:0] T_MEDIUM    = 20;
    localparam [TIME_WIDTH-1:0] T_HIGH      = 30;
    localparam [TIME_WIDTH-1:0] T_VERYHIGH  = 45;

    always @(posedge clk) begin
        if (rst) begin
            green_time <= T_LOW;
        end
        else begin
            case (density)
                2'b00: green_time <= T_LOW;
                2'b01: green_time <= T_MEDIUM;
                2'b10: green_time <= T_HIGH;
                2'b11: green_time <= T_VERYHIGH;
                default: green_time <= T_LOW;
            endcase
        end
    end

endmodule
