`timescale 1ns / 1ps
//==============================================================
// Module      : priority_controller
// Description : Detects emergency-vehicle sensor inputs on either
//               phase and requests an immediate override of the
//               normal FSM cycle so that phase can be forced green.
//==============================================================
module priority_controller (
    input  wire clk,
    input  wire rst,
    input  wire ns_emergency,      // emergency vehicle sensor, NS approach
    input  wire ew_emergency,      // emergency vehicle sensor, EW approach
    output reg  priority_override, // 1 = force a phase change now
    output reg  priority_direction // 0 = force NS green, 1 = force EW green
);

    always @(posedge clk) begin
        if (rst) begin
            priority_override <= 1'b0;
            priority_direction <= 1'b0;
        end
        else begin
            if (ns_emergency && !ew_emergency) begin
                priority_override  <= 1'b1;
                priority_direction <= 1'b0; // NS
            end
            else if (ew_emergency && !ns_emergency) begin
                priority_override  <= 1'b1;
                priority_direction <= 1'b1; // EW
            end
            else if (ns_emergency && ew_emergency) begin
                // Both sides signal at once: keep current direction,
                // just hold override so FSM finishes safely.
                priority_override  <= 1'b1;
            end
            else begin
                priority_override <= 1'b0;
            end
        end
    end

endmodule
