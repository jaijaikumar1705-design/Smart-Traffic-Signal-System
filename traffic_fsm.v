`timescale 1ns / 1ps
//==============================================================
// Module      : traffic_fsm
// Description : Core state machine that sequences the intersection
//               through NS_GREEN -> NS_YELLOW -> EW_GREEN ->
//               EW_YELLOW -> (repeat). Advances on timer_done.
//               Can be forced to a phase early by priority_override
//               from priority_controller.
//==============================================================
module traffic_fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire       timer_done,         // current phase timer expired
    input  wire       priority_override,  // force switch request
    input  wire       priority_direction, // 0 = NS, 1 = EW
    output reg  [1:0] active_phase,       // 00 NS_GREEN,01 NS_YELLOW,
                                          // 10 EW_GREEN,11 EW_YELLOW
    output reg        load_timer,         // pulse: load new phase duration
    output reg        use_green_time      // 1 = load green_time, 0 = fixed yellow
);

    localparam S_NS_GREEN  = 2'b00;
    localparam S_NS_YELLOW = 2'b01;
    localparam S_EW_GREEN  = 2'b10;
    localparam S_EW_YELLOW = 2'b11;

    reg [1:0] state, next_state;

    // ---------------- state register ----------------
    always @(posedge clk) begin
        if (rst)
            state <= S_NS_GREEN;
        else
            state <= next_state;
    end

    // ---------------- next-state logic ----------------
    always @(*) begin
        next_state = state;
        case (state)
            S_NS_GREEN: begin
                if (priority_override && priority_direction == 1'b1)
                    next_state = S_NS_YELLOW;      // yield to EW emergency
                else if (timer_done)
                    next_state = S_NS_YELLOW;
            end
            S_NS_YELLOW: begin
                if (timer_done)
                    next_state = S_EW_GREEN;
            end
            S_EW_GREEN: begin
                if (priority_override && priority_direction == 1'b0)
                    next_state = S_EW_YELLOW;      // yield to NS emergency
                else if (timer_done)
                    next_state = S_EW_YELLOW;
            end
            S_EW_YELLOW: begin
                if (timer_done)
                    next_state = S_NS_GREEN;
            end
            default: next_state = S_NS_GREEN;
        endcase
    end

    // ---------------- output logic ----------------
    // load_timer pulses for one cycle whenever we enter a new state
    reg [1:0] state_d;
    always @(posedge clk) begin
        if (rst)
            state_d <= S_NS_GREEN;
        else
            state_d <= state;
    end

    always @(*) begin
        active_phase   = state;
        load_timer     = (state != state_d);
        use_green_time = (state == S_NS_GREEN) || (state == S_EW_GREEN);
    end

endmodule
