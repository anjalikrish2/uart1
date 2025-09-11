`default_nettype none
`timescale 1ns / 1ps

//==============================================================================
// Merged UART Module (TX + RX)
//==============================================================================
module uart #(
    parameter SYSTEM_CLK = 100_000_000,
    parameter BAUDRATE   = 9600
)(
    input  wire        clk,
    input  wire        resetn,
    
    // TX Interface
    input  wire        tx_valid,
    input  wire [7:0]  tx_data,
    output wire        tx_ready,
    output wire        tx_out,
    
    // RX Interface
    input  wire        rx_pop,
    input  wire        rx_in,
    output wire [7:0]  rx_data,
    output wire        rx_valid,
    output wire        rx_error
);

    // TX UART Instance
    tx_uart #(
        .SYSTEM_CLK(SYSTEM_CLK),
        .BAUDRATE(BAUDRATE)
    ) tx_inst (
        .clk(clk),
        .resetn(resetn),
        .valid(tx_valid),
        .tx_data(tx_data),
        .div(32'd0),           // Use default baud rate calculation
        .tx_out(tx_out),
        .ready(tx_ready)
    );
    
    // RX UART Instance
    rx_uart #(
        .SYSTEM_CLK(SYSTEM_CLK),
        .BAUDRATE(BAUDRATE)
    ) rx_inst (
        .clk(clk),
        .resetn(resetn),
        .rx_in(rx_in),
        .rx_pop(rx_pop),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .error(rx_error)
    );

endmodule
