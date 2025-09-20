// modules/top.v
// Top-level module for the UART pattern matching system.

module top (
    input  wire sys_clk,   // 25 MHz system clock
    input  wire reset,     // Active-high reset
    input  wire rx_in,     // UART serial input
    output wire match      // Single-cycle pulse on pattern match
);

    // Internal signals
    wire baud_tick;
    wire serial_out;
    wire serial_valid;
    wire [7:0] sipo_out;
    wire match_async;

    // Instantiate the Baud Rate Generator
    baud_gen baud_gen_inst (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // Instantiate the UART Sampler
    uart_sampler uart_sampler_inst (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .rx_in(rx_in),
        .serial_out(serial_out),
        .serial_valid(serial_valid)
    );

    // Instantiate the SIPO Shift Register
    sipo_reg sipo_reg_inst (
        .clk(sys_clk),
        .reset(reset),
        .en(serial_valid),
        .serial_in(serial_out),
        .parallel_out(sipo_out)
    );

    wire match_comb;

    reg [7:0] sipo_out_reg;
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            sipo_out_reg <= 0;
        end else if (serial_valid) begin
            sipo_out_reg <= sipo_out;
        end
    end

    // Instantiate the Pattern Detector
    detector detector_inst (
        .data_in(sipo_out_reg[3:0]),
        .match(match_comb)
    );

    // Generate a single-cycle match pulse synchronous with sys_clk
    assign match = serial_valid & match_comb;

endmodule
