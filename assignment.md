# Assignment: FSM Design and RTL Implementation with UART Input (Bit-Level)  

## Context  
In this assignment, you will design, implement, and verify a **sequential digital circuit** using **Verilog**.  
The circuit combines concepts of **serial communication**, **shift registers**, **pattern detection**, and **clock domain crossing**.  

A key part of this exercise is to **critically reflect on your use of AI tools** (such as ChatGPT, Copilot, etc.) to assist your design process. The objective is not just to get working code, but to show how you engaged with the AI, refined your prompts, and evaluated the responses.  

---

## 📝 Problem Description  

You are tasked with implementing a **pattern detector system** that identifies a given 4-bit sequence in a serial input stream.  

- The **pattern to detect** is the **last decimal digit of your student identification card** or **your citizenship identification card**, converted into 4-bit binary.  
- The input arrives through a **UART line** at **115200 bps**, with frame format:  
  - 1 start bit (logic `0`)  
  - 8 data bits (LSB first)  
  - 1 stop bit (logic `1`)  
  - No parity  

👉 Example:  
- If the last digit of your ID card is `7`, the pattern is `0111`.  
- UART sends a frame with data bits: `01110101`.  
- The detector must assert `match = 1` for one **25 MHz system clock cycle** whenever the last 4 data bits equal `0111`.  
- Overlaps must be detected (e.g., `01110111` triggers twice).  

---

### Key Design Requirements  

1. **Baud-Rate Generator**  
   - Derive a tick signal from the 25 MHz system clock to sample bits at **115200 bps**.  

2. **UART Bit Sampler**  
   - Detect the **start bit** (falling edge `1 → 0`).  
   - Shift in the **8 data bits** (ignore the stop bit).  
   - Deliver each received data bit to the SIPO register.  

3. **SIPO Register**  
   - Implement an **8-bit shift register** clocked by the baud-rate tick.  
   - On every new data bit, shift it into the register.  
   - Continuously present the last 4 shifted bits for detection.  

4. **Pattern Detector**  
   - A **combinational circuit** compares the 4 least significant bits of the SIPO to the target pattern.  
   - If equal, assert `match = 1`.  
   - Output `match` must be synchronized into the **25 MHz system clock domain** and last exactly one cycle.  

5. **Top Module**  
   - Instantiates:  
     - Baud-rate generator  
     - UART bit sampler  
     - SIPO register  
     - Pattern detector  
     - Synchronizer to system clock  
   - Output: `match` pulse at 25 MHz clock.  

6. **Testbenches**  
   - Independent TBs for:  
     - Baud-rate generator  
     - UART sampler + SIPO  
     - Pattern detector  
     - Full top module  
   - Cover:  
     - Normal operation (correct detection)  
     - Overlapping patterns  
     - No matches  
     - Reset behavior  
     - Edge cases (noise on start/stop bits)  

---

## 📄 Deliverables  

Submit a **Git repository** containing:  

1. **Source Code**  
   - `baud_gen.v` → baud-rate generator  
   - `uart_sampler.v` → start-bit detection + bit sampling  
   - `sipo_reg.v` → shift register  
   - `detector.v` → 4-bit comparator  
   - `top.v` → integrated design  

2. **Testbenches**  
   - One TB for each module + full system.  

3. **Documentation** (`README.md` or PDF):  
   - Block diagram of the system, showing both clocks and synchronizer.  
   - Indicate your ID digit and its 4-bit binary equivalent.  
   - Test strategy and results.  

4. **AI Usage Report**  
   - State which AI tool(s) you used.  
   - Include the full chat or interaction history (relevant parts).  
   - Explain:  
     - How you structured prompts.  
     - How you refined them when results were incomplete/incorrect.  
     - What parts you accepted, rejected, or modified.  
   - Reflect briefly on how AI helped (or hindered) your design.  

---

## 📊 Evaluation Criteria  

- **Correctness** (25%)  
  - Baud-rate sampling works.  
  - Pattern detection works with overlaps.  
  - Reset and synchronization correct.  

- **Testbench Quality** (20%)  
  - Covers normal, overlapping, and error cases.  

- **Documentation** (20%)  
  - Clear diagrams and explanations.  
  - ID digit and binary mapping explicitly stated.  

- **AI Usage Report** (25%)  
  - Transcript complete.  
  - Prompts show iteration and reflection.  
  - Critical evaluation of AI responses.  

- **Code Style** (10%)  
  - Modular, clean, well-commented Verilog.  

---

## 💡 Hints & Recommendations  

- Use the baud-rate generator to sample the UART line at the correct bit intervals.  
- Skip start and stop bits: only shift data bits into the SIPO.  
- Combinational logic can continuously compare the last 4 SIPO bits with the pattern.  
- Synchronize the `match` signal into the 25 MHz domain with a 2-FF synchronizer.  
- For simulation, you may reduce baud rate and clock frequency to save simulation time.  

---

⚠️ **Important:** Using AI is allowed, but *blindly copy-pasting answers will result in a poor grade*. What matters is how you **control the AI to support your design process** and how you demonstrate **understanding**.
