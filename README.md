UART Module – SoC Project
README
Project Title: UART (Universal Asynchronous Receiver/Transmitter) Module for System-on-Chip
Overview:
This project implements a UART module as a peripheral inside a System-on-Chip (SoC) design. The UART enables serial communication between the SoC and external devices such as PCs, sensors, or microcontrollers. It supports configurable baud rate, transmit and receive functionality, and status flag monitoring.
Features:
• Full-duplex asynchronous serial communication
• Supports standard UART frame format (1 start bit, 8 data bits, 1 stop bit)
• Configurable baud rate through divisor registers
• Transmit (TX) and Receive (RX) buffers
• Status flags: TX busy, RX ready, parity error (if applicable)
• Memory-mapped register interface for integration with CPU bus
• Synthesizable RTL compatible with FPGA and ASIC SoC designs
Directory Structure:
• rtl/ – Verilog/SystemVerilog source code for the UART
• sim/ – Testbench and simulation files
• docs/ – Architecture, state diagrams, waveforms
• scripts/ – Automation scripts for build or simulation
• constraints/ – FPGA or SoC-level integration constraints (optional)
How It Works:
The CPU writes outgoing data to the UART transmit register.
The TX module serializes the data and transmits it on the TX line.
Incoming serial data on the RX line is deserialized and stored in the RX buffer.
The CPU reads the received data from the memory-mapped RX register.
Status registers indicate module readiness, busy state, and errors.
Memory-Mapped Register Overview:
• DATA_TX: Write data to transmit
• DATA_RX: Read received data
• STATUS: Flags for TX busy, RX ready, error
• BAUD_DIV: Baud rate divisor register
Baud Rate Calculation:
baud_rate = clock_frequency / (16 × divisor)
Example:
For a 50 MHz clock and 115200 baud:
divisor = 50,000,000 / (16 × 115200) ≈ 27
Testbench:
The included testbench verifies the following:
• Correct TX serialization
• RX sampling at correct mid-bit intervals
• Baud rate accuracy
• Error detection for incorrect frames
Integration Notes:
• Connect UART memory-mapped interface to SoC bus (APB/AHB/Avalon etc.)
• Ensure clock domain crossing if bus and UART use different clocks
• TX and RX pins must be routed externally on FPGA or chip I/O
• Modify BAUD_DIV register for custom baud rates
Simulation Instructions:
Navigate to sim/
Compile RTL and testbench with your preferred simulator
Run simulation and inspect waveforms for TX and RX behavior
Verify that the testbench passes all assertions
Synthesis Instructions:
Include rtl/ directory in your FPGA or ASIC build flow
Configure top-level I/O for uart_tx and uart_rx
Verify timing constraints for desired baud rate
