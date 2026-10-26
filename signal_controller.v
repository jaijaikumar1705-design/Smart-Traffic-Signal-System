`timescale 1ns / 1ps
//==============================================================
// Module      : signal_controller
// Description : Translates the FSM's active_phase into the actual
//               Red / Yellow / Green outputs for all four approach
//               directions of the intersection.
//==============================================================
module signal_controller (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] active_phase, // 00 NS_GREEN,01 NS_YELLOW,
                                     // 10 EW_GREEN,11 EW_YELLOW
    output reg  n_red, n_yellow, n_green,
    output reg  s_red, s_yellow, s_green,
    output reg  e_red, e_yellow, e_green,
    output reg  w_red, w_yellow, w_green
);

    localparam S_NS_GREEN  = 2'b00;
    localparam S_NS_YELLOW = 2'b01;
    localparam S_EW_GREEN  = 2'b10;
    localparam S_EW_YELLOW = 2'b11;

    always @(posedge clk) begin
        if (rst) begin
            {n_red, n_yellow, n_green} <= 3'b100;
            {s_red, s_yellow, s_green} <= 3'b100;
            {e_red, e_yellow, e_green} <= 3'b100;
            {w_red, w_yellow, w_green} <= 3'b100;
        end
        else begin
            case (active_phase)
                S_NS_GREEN: begin
                    {n_red, n_yellow, n_green} <= 3'b001;
                    {s_red, s_yellow, s_green} <= 3'b001;
                    {e_red, e_yellow, e_green} <= 3'b100;
                    {w_red, w_yellow, w_green} <= 3'b100;
                end
                S_NS_YELLOW: begin
                    {n_red, n_yellow, n_green} <= 3'b010;
                    {s_red, s_yellow, s_green} <= 3'b010;
                    {e_red, e_yellow, e_green} <= 3'b100;
                    {w_red, w_yellow, w_green} <= 3'b100;
                end
                S_EW_GREEN: begin
                    {n_red, n_yellow, n_green} <= 3'b100;
                    {s_red, s_yellow, s_green} <= 3'b100;
                    {e_red, e_yellow, e_green} <= 3'b001;
                    {w_red, w_yellow, w_green} <= 3'b001;
                end
                S_EW_YELLOW: begin
                    {n_red, n_yellow, n_green} <= 3'b100;
                    {s_red, s_yellow, s_green} <= 3'b100;
                    {e_red, e_yellow, e_green} <= 3'b010;
                    {w_red, w_yellow, w_green} <= 3'b010;
                end
                default: begin
                    {n_red, n_yellow, n_green} <= 3'b100;
                    {s_red, s_yellow, s_green} <= 3'b100;
                    {e_red, e_yellow, e_green} <= 3'b100;
                    {w_red, w_yellow, w_green} <= 3'b100;
                end
            endcase
        end
    end

endmodule
