// modules/sipo_reg.v
// An 8-bit Serial-In, Parallel-Out (SIPO) shift register.

module sipo_reg (
    input  wire       clk,        // Clock (driven by baud_tick)
    input  wire       reset,      // Asynchronous reset
    input  wire       en,         // Clock enable
    input  wire       serial_in,  // Serial data input
    output reg  [7:0] parallel_out // Parallel data output
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parallel_out <= 8'b0;
        end else if (en) begin
            // Shift in the new bit only when enabled.
            // The new bit becomes the MSB, and the rest shift right.
            // The oldest bit is at the LSB.
            parallel_out <= {serial_in, parallel_out[7:1]};
        end
    end

endmodule
