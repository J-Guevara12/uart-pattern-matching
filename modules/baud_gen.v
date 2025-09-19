// baud_gen.v
// Generates a baud rate tick from a system clock.

module baud_gen (
    input  wire sys_clk,   // System clock (25 MHz)
    input  wire reset,     // Asynchronous reset
    output reg  baud_tick  // Tick at baud rate (115200 Hz)
);

    // System clock frequency = 25,000,000 Hz
    // Baud rate = 115,200 bps
    // Counter limit = (25,000,000 / 115,200) = 217.0138...
    localparam COUNTER_LIMIT = 217;

    reg [$clog2(COUNTER_LIMIT)-1:0] counter;

    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            baud_tick <= 0;
        end else begin
            if (counter == COUNTER_LIMIT - 1) begin
                counter <= 0;
                baud_tick <= 1;
            end else begin
                counter <= counter + 1;
                baud_tick <= 0;
            end
        end
    end

endmodule
