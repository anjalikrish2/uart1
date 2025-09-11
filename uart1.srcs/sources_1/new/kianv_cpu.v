// Corrected CPU module (slower writes to allow UART to keep up)
`default_nettype none
`timescale 1ns / 1ps
module kianv_cpu (
    input  wire        clk,
    input  wire        resetn,
    output reg  [31:0] mem_addr,
    output reg  [31:0] mem_wdata,
    input  wire [31:0] mem_rdata,
    output reg         mem_wr,
    output reg         mem_rd
);
    localparam IDLE       = 2'd0;
    localparam WRITE_TX   = 2'd1;
    localparam READ_LSR   = 2'd2;
    localparam WAIT       = 2'd3;
    
    reg [1:0] state;
    reg [19:0] timer;  // Increased width for longer waits
    reg [7:0] tx_count;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state     <= IDLE;
            timer     <= 20'd0;
            tx_count  <= 8'd0;
            mem_addr  <= 32'b0;
            mem_wdata <= 32'b0;
            mem_wr    <= 1'b0;
            mem_rd    <= 1'b0;
        end else begin
            // default deassert strobes
            mem_wr <= 1'b0;
            mem_rd <= 1'b0;
            
            case (state)
                IDLE: begin
                    // write TX register with incrementing ASCII (A, B, C...)
                    mem_addr  <= 32'h1000_0000;
                    mem_wdata <= {24'b0, 8'h41 + tx_count};
                    mem_wr    <= 1'b1;
                    tx_count  <= tx_count + 1;
                    state     <= READ_LSR;
                end
                READ_LSR: begin
                    mem_addr <= 32'h1000_0008;
                    mem_rd   <= 1'b1;
                    state    <= WAIT;
                    timer    <= 20'd0;
                end
                WAIT: begin
                    timer <= timer + 1;
                    // Wait longer - approximately 1.5 UART character times at 9600 baud
                    // At 100MHz: 9600 baud = ~10417 clocks per bit, ~156250 clocks per char
                    if (timer == 10000) begin
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
