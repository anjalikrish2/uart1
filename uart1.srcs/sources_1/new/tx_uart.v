//==============================================================================
// TX UART Module
//==============================================================================
module tx_uart #(
    parameter SYSTEM_CLK = 100_000_000,
    parameter BAUDRATE   = 9600
)(
    input  wire        clk,
    input  wire        resetn,
    input  wire        valid,
    input  wire [7:0]  tx_data,
    input  wire [31:0] div,         // Optional precomputed cycles per symbol
    output reg         tx_out,
    output wire        ready
);

    // Compute cycles per symbol
    wire [31:0] cycles_per_symbol;
    assign cycles_per_symbol = (div != 32'd0) ? div : (SYSTEM_CLK / BAUDRATE);
    
    // State encoding
    localparam IDLE      = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT  = 3'd3;
    
    reg [2:0]  state;
    reg [2:0]  bit_idx;
    reg [7:0]  tx_data_reg;
    reg [31:0] wait_cnt;
    reg        tx_busy;
    
    assign ready = ~tx_busy;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            tx_out      <= 1'b1;    // UART TX idles HIGH
            state       <= IDLE;
            bit_idx     <= 3'd0;
            tx_data_reg <= 8'd0;
            wait_cnt    <= 32'd0;
            tx_busy     <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_out <= 1'b1;    // Ensure idle HIGH
                    if (valid && !tx_busy) begin
                        tx_data_reg <= tx_data;
                        tx_busy     <= 1'b1;
                        tx_out      <= 1'b0;   // Start bit
                        wait_cnt    <= cycles_per_symbol - 1;
                        state       <= START_BIT;
                        bit_idx     <= 3'd0;
                    end
                end
                
                START_BIT: begin
                    if (wait_cnt == 32'd0) begin
                        tx_out   <= tx_data_reg[0];
                        wait_cnt <= cycles_per_symbol - 1;
                        bit_idx  <= 3'd1;
                        state    <= DATA_BITS;
                    end else begin
                        wait_cnt <= wait_cnt - 1;
                    end
                end
                
                DATA_BITS: begin
                    if (wait_cnt == 32'd0) begin
                        if (bit_idx == 3'd7) begin
                            tx_out   <= 1'b1;     // Stop bit
                            wait_cnt <= cycles_per_symbol - 1;
                            state    <= STOP_BIT;
                        end else begin
                            bit_idx  <= bit_idx + 1;
                            tx_out   <= tx_data_reg[bit_idx + 1];
                            wait_cnt <= cycles_per_symbol - 1;
                        end
                    end else begin
                        wait_cnt <= wait_cnt - 1;
                    end
                end
                
                STOP_BIT: begin
                    if (wait_cnt == 32'd0) begin
                        tx_busy <= 1'b0;
                        state   <= IDLE;
                    end else begin
                        wait_cnt <= wait_cnt - 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule

