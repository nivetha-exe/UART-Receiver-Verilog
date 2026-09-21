# UART Receiver - Verilog

A Verilog RTL implementation of an 8-bit UART receiver.

## Features
- 50 MHz clock
- 9600 baud rate
- 8-bit data reception
- LSB-first reception
- Start and stop bit detection
- FSM-based design
- Baud-rate sampling
- Data valid signal
- Busy status signal

## Files
- `uart_rx.v` - UART receiver RTL
- `uart_rx_tb.v` - Testbench

## UART Frame
1 Start bit + 8 Data bits + 1 Stop bit

## Simulation Result
Successfully received:

`10110010`

Output:

`0xB2`
