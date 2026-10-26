`timescale 1ns / 1ps
//==============================================================
// Module      : traffic_tb
// Description : Self-checking-ish testbench for traffic_top.
//               Uses a small CLK_FREQ_HZ so the 1-second tick
//               (and hence whole light cycles) happen quickly
//               in simulation instead of waiting for a real
//               100 MHz divide-down.
//==============================================================
module traffic_tb;

    // Small divider so 1 "second" = 10 clock cycles in sim
    localparam CLK_FREQ_HZ = 10;
    localparam CNT_WIDTH   = 8;
    localparam TIME_WIDTH  = 8;

    reg                   clk;
    reg                   rst;
    reg  [CNT_WIDTH-1:0]  ns_count;
    reg  [CNT_WIDTH-1:0]  ew_count;
    reg                   ns_emergency;
    reg                   ew_emergency;

    wire n_red, n_yellow, n_green;
    wire s_red, s_yellow, s_green;
    wire e_red, e_yellow, e_green;
    wire w_red, w_yellow, w_green;

    //----------------------------------------------------------
    // DUT instantiation
    //----------------------------------------------------------
    traffic_top #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .CNT_WIDTH   (CNT_WIDTH),
        .TIME_WIDTH  (TIME_WIDTH)
    ) DUT (
        .clk          (clk),
        .rst          (rst),
        .ns_count     (ns_count),
        .ew_count     (ew_count),
        .ns_emergency (ns_emergency),
        .ew_emergency (ew_emergency),
        .n_red(n_red), .n_yellow(n_yellow), .n_green(n_green),
        .s_red(s_red), .s_yellow(s_yellow), .s_green(s_green),
        .e_red(e_red), .e_yellow(e_yellow), .e_green(e_green),
        .w_red(w_red), .w_yellow(w_yellow), .w_green(w_green)
    );

    //----------------------------------------------------------
    // Clock generation: 10 ns period (100 MHz equivalent scale)
    //----------------------------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    //----------------------------------------------------------
    // Stimulus
    //----------------------------------------------------------
    initial begin
        rst          = 1'b1;
        ns_count     = 8'd10;   // LOW density
        ew_count     = 8'd10;   // LOW density
        ns_emergency = 1'b0;
        ew_emergency = 1'b0;

        repeat (5) @(posedge clk);
        rst = 1'b0;

        // ---- Phase 1: low density both directions ----
        #500;

        // ---- Phase 2: raise EW density to HIGH ----
        ew_count = 8'd90;   // VERY HIGH -> longer EW green
        ns_count = 8'd5;    // LOW
        #800;

        // ---- Phase 3: trigger an NS emergency override ----
        ns_emergency = 1'b1;
        #100;
        ns_emergency = 1'b0;
        #500;

        // ---- Phase 4: medium density both directions ----
        ns_count = 8'd35;
        ew_count = 8'd35;
        #800;

        $display("Simulation complete at time %0t", $time);
        $finish;
    end

    //----------------------------------------------------------
    // Monitor: print light state whenever it changes
    //----------------------------------------------------------
    initial begin
        $monitor("t=%0t | NS(R=%b Y=%b G=%b) EW(R=%b Y=%b G=%b) | ns_cnt=%0d ew_cnt=%0d",
                 $time,
                 n_red, n_yellow, n_green,
                 e_red, e_yellow, e_green,
                 ns_count, ew_count);
    end

endmodule
