
//==============================================================================
// RX UART Module
//==============================================================================
module rx_uart #(
    parameter SYSTEM_CLK = 100_000_000,
    parameter BAUDRATE   = 9600
)(
    input  wire        clk,
    input  wire        resetn,
    input  wire        rx_in,
    input  wire        rx_pop,     // Consumer clears valid
    output reg  [7:0]  rx_data,
    output reg         rx_valid,
    output reg         error
);

    // Compute cycles per symbol
    localparam integer CYCLES_PER_SYMBOL = SYSTEM_CLK / BAUDRATE;
    localparam integer HALF_SYMBOL = CYCLES_PER_SYMBOL / 2;
    
    // Input synchronizer (2 FF synchronizer)
    reg [2:0] rx_sync;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) 
            rx_sync <= 3'b111;
        else 
            rx_sync <= {rx_sync[1:0], rx_in};
    end
    
    // State encoding
    localparam IDLE         = 2'd0;
    localparam START_BIT    = 2'd1;
    localparam DATA_BITS    = 2'd2;
    localparam STOP_BIT     = 2'd3;
    
    reg [1:0]  state;
    reg [15:0] bit_timer;
    reg [2:0]  bit_idx;
    reg [7:0]  shift_reg;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state     <= IDLE;
            rx_valid  <= 1'b0;
            rx_data   <= 8'd0;
            error     <= 1'b0;
            bit_timer <= 16'd0;
            bit_idx   <= 3'd0;
            shift_reg <= 8'd0;
        end else begin
            
            // Clear valid on pop
            if (rx_pop) 
                rx_valid <= 1'b0;
                
            case (state)
                IDLE: begin
                    error <= 1'b0;
                    // Detect start bit (falling edge: 1->0)
                    if (rx_sync[2:1] == 2'b10) begin
                        bit_timer <= HALF_SYMBOL;  // Wait to center of first data bit
                        bit_idx   <= 3'd0;
                        state     <= START_BIT;
                    end
                end
                
                START_BIT: begin
                    if (bit_timer == 16'd0) begin
                        // Verify start bit is still low
                        if (rx_sync[2] == 1'b0) begin
                            bit_timer <= CYCLES_PER_SYMBOL - 1;
                            state     <= DATA_BITS;
                        end else begin
                            error <= 1'b1;
                            state <= IDLE;
                        end
                    end else begin
                        bit_timer <= bit_timer - 1;
                    end
                end
                
                DATA_BITS: begin
                    if (bit_timer == 16'd0) begin
                        // Sample data bit
                        shift_reg[bit_idx] <= rx_sync[2];
                        bit_idx <= bit_idx + 1;
                        
                        if (bit_idx == 3'd7) begin
                            // Last data bit, prepare for stop bit
                            bit_timer <= CYCLES_PER_SYMBOL - 1;
                            state     <= STOP_BIT;
                        end else begin
                            bit_timer <= CYCLES_PER_SYMBOL - 1;
                        end
                    end else begin
                        bit_timer <= bit_timer - 1;
                    end
                end
                
                STOP_BIT: begin
                    if (bit_timer == 16'd0) begin
                        // Check stop bit is high
                        if (rx_sync[2] == 1'b1) begin
                            rx_data  <= shift_reg;
                            rx_valid <= 1'b1;
                            error    <= 1'b0;
                        end else begin
                            error <= 1'b1;
                        end
                        state <= IDLE;
                    end else begin
                        bit_timer <= bit_timer - 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule