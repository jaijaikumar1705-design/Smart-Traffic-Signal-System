`timescale 1ns / 1ps
//==============================================================
// Module      : density_analyzer
// Description : Reads vehicle-count sensor values for the two
//               traffic phases (North-South group and East-West
//               group) and classifies each into a 2-bit density
//               level:
//                  00 = LOW
//                  01 = MEDIUM
//                  10 = HIGH
//                  11 = VERY HIGH
//==============================================================
module density_analyzer #(
    parameter CNT_WIDTH = 8
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire [CNT_WIDTH-1:0]   ns_count,   // vehicles waiting N+S
    input  wire [CNT_WIDTH-1:0]   ew_count,   // vehicles waiting E+W
    output reg  [1:0]             ns_density,
    output reg  [1:0]             ew_density
);

    // Threshold constants (tune to your sensor scaling)
    localparam [CNT_WIDTH-1:0] TH_LOW  = 20;
    localparam [CNT_WIDTH-1:0] TH_MED  = 50;
    localparam [CNT_WIDTH-1:0] TH_HIGH = 80;

    function [1:0] classify;
        input [CNT_WIDTH-1:0] cnt;
        begin
            if (cnt < TH_LOW)
                classify = 2'b00;      // LOW
            else if (cnt < TH_MED)
                classify = 2'b01;      // MEDIUM
            else if (cnt < TH_HIGH)
                classify = 2'b10;      // HIGH
            else
                classify = 2'b11;      // VERY HIGH
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            ns_density <= 2'b00;
            ew_density <= 2'b00;
        end
        else begin
            ns_density <= classify(ns_count);
            ew_density <= classify(ew_count);
        end
    end

endmodule
