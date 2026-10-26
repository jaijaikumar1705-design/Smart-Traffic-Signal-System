`timescale 1ns / 1ps
//==============================================================
// Module      : traffic_top
// Description : Top-level integration of the adaptive traffic
//               light controller. Instantiates the density
//               analyzer, time allocator, timer, priority
//               controller, FSM, and signal controller, and
//               generates a 1-second tick from the board clock.
//
// Notes       : CLK_FREQ_HZ should be set to your board's actual
//               clock frequency (default assumes 100 MHz, typical
//               of many Xilinx dev boards). This is used purely to
//               derive the 1 Hz enable tick for the timer.
//==============================================================
module traffic_top #(
    parameter CLK_FREQ_HZ = 100_000_000,
    parameter CNT_WIDTH   = 8,
    parameter TIME_WIDTH  = 8
)(
    input  wire                  clk,
    input  wire                  rst,

    // sensor inputs (vehicle counts waiting at each approach group)
    input  wire [CNT_WIDTH-1:0]  ns_count,
    input  wire [CNT_WIDTH-1:0]  ew_count,

    // emergency vehicle sensors
    input  wire                  ns_emergency,
    input  wire                  ew_emergency,

    // physical light outputs
    output wire n_red, n_yellow, n_green,
    output wire s_red, s_yellow, s_green,
    output wire e_red, e_yellow, e_green,
    output wire w_red, w_yellow, w_green
);

    // Fixed yellow-light duration in seconds
    localparam [TIME_WIDTH-1:0] YELLOW_TIME = 3;

    //----------------------------------------------------------
    // 1 Hz tick generator (divides board clock down to 1 pulse/sec)
    //----------------------------------------------------------
    reg [31:0] div_cnt;
    reg        tick_1sec;

    always @(posedge clk) begin
        if (rst) begin
            div_cnt   <= 32'd0;
            tick_1sec <= 1'b0;
        end
        else if (div_cnt == CLK_FREQ_HZ - 1) begin
            div_cnt   <= 32'd0;
            tick_1sec <= 1'b1;
        end
        else begin
            div_cnt   <= div_cnt + 1'b1;
            tick_1sec <= 1'b0;
        end
    end

    //----------------------------------------------------------
    // Internal wires
    //----------------------------------------------------------
    wire [1:0]            ns_density, ew_density;
    wire [TIME_WIDTH-1:0] ns_green_time, ew_green_time;
    wire                  priority_override, priority_direction;
    wire [1:0]            active_phase;
    wire                  load_timer, use_green_time;
    wire                  timer_done;
    wire [TIME_WIDTH-1:0] timer_load_value;
    wire [TIME_WIDTH-1:0] timer_count;

    // Select which green_time to feed the timer based on current phase
    assign timer_load_value = (!use_green_time)            ? YELLOW_TIME :
                               (active_phase == 2'b00)     ? ns_green_time :
                                                              ew_green_time;

    //----------------------------------------------------------
    // Sub-module instantiations
    //----------------------------------------------------------
    density_analyzer #(
        .CNT_WIDTH(CNT_WIDTH)
    ) u_density_analyzer (
        .clk        (clk),
        .rst        (rst),
        .ns_count   (ns_count),
        .ew_count   (ew_count),
        .ns_density (ns_density),
        .ew_density (ew_density)
    );

    time_allocator #(
        .TIME_WIDTH(TIME_WIDTH)
    ) u_time_allocator_ns (
        .clk        (clk),
        .rst        (rst),
        .density    (ns_density),
        .green_time (ns_green_time)
    );

    time_allocator #(
        .TIME_WIDTH(TIME_WIDTH)
    ) u_time_allocator_ew (
        .clk        (clk),
        .rst        (rst),
        .density    (ew_density),
        .green_time (ew_green_time)
    );

    priority_controller u_priority_controller (
        .clk                 (clk),
        .rst                 (rst),
        .ns_emergency        (ns_emergency),
        .ew_emergency        (ew_emergency),
        .priority_override   (priority_override),
        .priority_direction  (priority_direction)
    );

    traffic_fsm u_traffic_fsm (
        .clk                 (clk),
        .rst                 (rst),
        .timer_done          (timer_done),
        .priority_override   (priority_override),
        .priority_direction  (priority_direction),
        .active_phase        (active_phase),
        .load_timer          (load_timer),
        .use_green_time      (use_green_time)
    );

    timer #(
        .WIDTH(TIME_WIDTH)
    ) u_timer (
        .clk         (clk),
        .rst         (rst),
        .load        (load_timer),
        .load_value  (timer_load_value),
        .enable      (tick_1sec),
        .done        (timer_done),
        .count       (timer_count)
    );

    signal_controller u_signal_controller (
        .clk           (clk),
        .rst           (rst),
        .active_phase  (active_phase),
        .n_red(n_red), .n_yellow(n_yellow), .n_green(n_green),
        .s_red(s_red), .s_yellow(s_yellow), .s_green(s_green),
        .e_red(e_red), .e_yellow(e_yellow), .e_green(e_green),
        .w_red(w_red), .w_yellow(w_yellow), .w_green(w_green)
    );

endmodule
