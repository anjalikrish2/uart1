`timescale 1ns/1ps

module tb_soc;
    reg clk;
    reg resetn;
    reg uart_rx;
    wire uart_tx;

    // Instantiate DUT (soc_top)
    soc_top dut (
        .clk    (clk),
        .resetn (resetn),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // Clock generator: 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset sequence (active-low)
    initial begin
        resetn = 0;      // hold in reset
        uart_rx = 1;     // idle line
        #100;
        resetn = 1;      // release reset after 100 ns
    end

    // Stimulus
    initial begin
        // Wait for reset release
        @(posedge resetn);

        // Send a byte (0x55) into RX
        #1000;
        send_byte(8'h55);

        // Wait some time for DUT response
        #200000;
        $finish;
    end

    // Task: send serial byte into uart_rx
    task send_byte(input [7:0] b);
        integer i;
        begin
            // Start bit
            uart_rx = 0;
            #(104160); // 9600 baud at 100 MHz → ~104160 ns per bit

            // Data bits (LSB first)
            for (i=0; i<8; i=i+1) begin
                uart_rx = b[i];
                #(104160);
            end

            // Stop bit
            uart_rx = 1;
            #(104160);
        end
    endtask

endmodule
