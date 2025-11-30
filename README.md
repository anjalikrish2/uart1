# UART Module – SoC Project

A synthesizable UART peripheral for System-on-Chip designs, enabling serial communication with external devices.

---

## Overview

This project implements a **UART (Universal Asynchronous Receiver/Transmitter)** module designed for integration as a peripheral in System-on-Chip (SoC) architectures. The module provides full-duplex serial communication with configurable baud rates and memory-mapped register access, making it suitable for communication with PCs, sensors, microcontrollers, and other serial devices.

---

## Features

- **Full-duplex asynchronous serial communication**
- **Standard UART frame format**: 1 start bit, 8 data bits, 1 stop bit
- **Configurable baud rate** via divisor registers
- **Transmit (TX) and Receive (RX) buffers**
- **Status flags**: TX busy, RX ready, parity error detection
- **Memory-mapped register interface** for CPU bus integration
- **Synthesizable RTL** compatible with FPGA and ASIC flows

---


```

---

## How It Works

1. **Transmit Path**: The CPU writes data to the UART transmit register. The TX module serializes the byte and sends it bit-by-bit over the TX line.

2. **Receive Path**: Incoming serial data on the RX line is sampled, deserialized, and stored in the RX buffer for CPU retrieval.

3. **Status Monitoring**: Status registers provide real-time information about module state (busy, data ready, errors).

4. **Register Access**: All configuration and data transfer occurs through memory-mapped registers accessible via the SoC bus.

---

## Memory-Mapped Registers

| Register   | Access | Description                          |
|------------|--------|--------------------------------------|
| `DATA_TX`  | Write  | Transmit data register               |
| `DATA_RX`  | Read   | Receive data register                |
| `STATUS`   | Read   | Status flags (TX busy, RX ready, error) |
| `BAUD_DIV` | R/W    | Baud rate divisor configuration      |

---

## Baud Rate Configuration

The baud rate is determined by the clock frequency and divisor value:

```
baud_rate = clock_frequency / (16 × divisor)
```

**Example**: For a 50 MHz system clock targeting 115200 baud:

```
divisor = 50,000,000 / (16 × 115200) ≈ 27
```

Write `27` to the `BAUD_DIV` register to configure this rate.

---

## Testbench

The included testbench validates:

- Correct TX bit serialization and timing
- RX sampling at proper mid-bit intervals
- Baud rate accuracy
- Frame error detection
- Register read/write operations

---

## Simulation Instructions

1. Navigate to the `sim/` directory
2. Compile RTL and testbench using your preferred simulator (ModelSim, VCS, Verilator, etc.)
3. Run the simulation and inspect waveforms for TX/RX behavior
4. Verify all testbench assertions pass

---

## Integration Guidelines

### Bus Interface
- Connect the UART's memory-mapped interface to your SoC bus (APB, AHB, or custom)
- Ensure proper address decoding for UART register space

### Clock Domains
- Handle clock domain crossing if the SoC bus and UART operate on different clocks
- Use synchronizers for status signals crossing domains

### I/O Routing
- Route `uart_tx` and `uart_rx` pins to external chip I/O
- Configure appropriate I/O standards and voltage levels

### Configuration
- Initialize `BAUD_DIV` register during system startup
- Configure any optional parity or flow control features

---

## Synthesis Instructions

1. Add the `rtl/` directory to your FPGA or ASIC synthesis project
2. Configure top-level I/O constraints for `uart_tx` and `uart_rx` pins
3. Apply timing constraints to meet the required baud rate timing
4. Verify synthesis reports for timing closure and resource utilization


