`timescale 1ns / 1ps
//==============================================================
// Module      : timer
// Description : Generic down-counter used to time each traffic
//               light phase. Counts down (on a 1-tick-per-second
//               "enable" pulse) from load_value to 0 and asserts
//               'done' for one cycle when it reaches zero.
//==============================================================
module timer #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,        // synchronous, active-high
    input  wire             load,       // pulse: load load_value into counter
    input  wire [WIDTH-1:0] load_value, // seconds to count down from
    input  wire             enable,     // 1-second tick enable
    output reg               done,      // pulses high for 1 cycle at 0
    output reg  [WIDTH-1:0] count       // current count (for display/debug)
);

    always @(posedge clk) begin
        if (rst) begin
            count <= {WIDTH{1'b0}};
            done  <= 1'b0;
        end
        else if (load) begin
            count <= load_value;
            done  <= 1'b0;
        end
        else if (enable) begin
            if (count == {WIDTH{1'b0}}) begin
                done  <= 1'b1;   // already at zero -> signal expiry
                count <= count;
            end
            else if (count == {{(WIDTH-1){1'b0}}, 1'b1}) begin
                // about to reach zero this tick
                count <= count - 1'b1;
                done  <= 1'b1;
            end
            else begin
                count <= count - 1'b1;
                done  <= 1'b0;
            end
        end
        else begin
            done <= 1'b0;
        end
    end

endmodule
