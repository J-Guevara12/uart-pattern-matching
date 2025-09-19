# UART Pattern Matching FSM

This project implements a pattern detector system that identifies a given 4-bit sequence in a serial input stream received via UART.

## Modules

### 1. Baud Rate Generator (`baud_gen.v`)

This module generates a sampling tick at the specified baud rate from a higher-frequency system clock.

**Functionality:**
- **Input:** 25 MHz system clock (`sys_clk`), active-high reset (`reset`).
- **Output:** A single-cycle pulse (`baud_tick`) at 115200 Hz.

The generator is implemented using a counter that divides the 25 MHz system clock by 217 to approximate the 115200 bps baud rate. The `baud_tick` is asserted for one `sys_clk` cycle when the counter reaches its limit.

#### Testbench and Verification

The testbench (`testbenches/baud_gen_tb.v`) is designed to verify the correct timing of the `baud_tick` signal.

**Test Strategy:**
1.  **Clock Generation:** A 25 MHz `sys_clk` is generated with a period of 40 ns.
2.  **Reset Sequence:** The simulation starts with the `reset` signal asserted for 100 ns to ensure the module initializes correctly. After 100 ns, the reset is de-asserted, and the counter begins.
3.  **Observation:** The simulation runs for 10 µs to allow for multiple ticks to be generated and observed.

**Simulation Results Analysis:**


**Expected vs. Actual Tick Time:**
- The system clock period is 40 ns.
- The counter limit is 217.
- The reset is held for 100 ns.

The first `baud_tick` is expected to occur after the reset period plus the time it takes for the counter to reach its limit:
- Expected Time = `Reset Time` + (`COUNTER_LIMIT` * `Clock Period`)
- Expected Time = 100 ns + (217 * 40 ns) = 100 ns + 8680 ns = **8780 ns**

The simulation output shows the first tick occurring at `8780000 ps` or `8780 ns`, which exactly matches the expected calculation. This confirms that the baud rate generator is functioning correctly.

For a more detailed analysis, the full waveform can be inspected in the VCD file located at `dumpvars/baud_gen.vcd`.

**Waveform:**

The following waveform shows the `baud_tick` being asserted periodically.

![Baud Gen Waveform](images/baud_gen.png)

### 2. UART Sampler (`uart_sampler.v`)

This module is responsible for detecting a UART frame, sampling the 8 data bits, and outputting the received byte.

**Functionality:**
- **Inputs:** `sys_clk`, `reset`, `baud_tick` (from `baud_gen`), and the serial input `rx_in`.
- **Outputs:** `data_out` (the 8-bit received byte) and `data_valid` (a single-cycle pulse indicating new data is available).

The sampler uses a four-state finite state machine (FSM) to process the UART frame:
-   **IDLE:** Waits for a falling edge on `rx_in`, which signals the start bit.
-   **START_BIT:** Waits for the first `baud_tick` to synchronize the sampling process to the middle of the bit period.
-   **SAMPLING:** On the next 8 consecutive `baud_tick`s, it samples the `rx_in` line and shifts the data bits into an internal register.
-   **STOP_BIT:** Waits for one final `baud_tick` to cover the stop bit period, then asserts `data_valid` and makes the `data_out` available.

#### Testbench and Verification

The testbench (`testbenches/uart_sampler_tb.v`) verifies that the sampler can correctly receive a standard UART frame.

**Test Strategy:**
1.  **Frame Generation:** A task `send_uart_frame` is used to generate a UART frame with a start bit, 8 data bits (LSB first), and a stop bit.
2.  **Test Cases:** The testbench sends two bytes back-to-back: `8'hD6` (`11010110`) and `8'h35` (`00110101`).
3.  **Verification:** The `data_out` and `data_valid` signals are monitored to confirm that the bytes are received correctly.

**Simulation Results Analysis:**

- The first byte, `D6`, is correctly received, and `data_valid` is asserted at `t = 86.9 ns`.
- The second byte, `35`, is correctly received, and `data_valid` is asserted at `t = 191.06 ns`.

The simulation VCD is available at `var_dumps/uart_sampler.vcd`.

**Waveform:**

The waveform below shows the `rx_in` signal transmitting the byte `D6` and the corresponding `data_out` and `data_valid` signals after reception.

![UART Sampler Waveform](images/uart_sampler.png)
