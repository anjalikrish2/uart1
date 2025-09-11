//==============================================================================
// SoC Top Module with Memory-Mapped UART
//==============================================================================
module soc_top #(
    parameter SYSTEM_CLK = 100_000_000,
    parameter BAUDRATE   = 9600
)(
    input  wire        clk,
    input  wire        resetn,
    // UART pins
    input  wire        uart_rx,
    output wire        uart_tx
);

    //----------------------------
    // CPU <-> Memory Interface
    //----------------------------
    wire [31:0] cpu_mem_addr;
    wire [31:0] cpu_mem_wdata;
    wire [31:0] cpu_mem_rdata;
    wire        cpu_mem_wr;
    wire        cpu_mem_rd;
    
    //----------------------------
    // UART Interface Signals
    //----------------------------
    wire        uart_tx_valid;
    wire        uart_tx_ready;
    wire [7:0]  uart_rx_data;
    wire        uart_rx_valid;
    wire        uart_rx_pop;
    wire        uart_rx_error;
    
    //----------------------------
    // Memory Map Addresses
    //----------------------------
    localparam UART_TX_ADDR  = 32'h1000_0000;  // Write: Transmit data
    localparam UART_RX_ADDR  = 32'h1000_0004;  // Read: Receive data
    localparam UART_LSR_ADDR = 32'h1000_0008;  // Read: Line Status Register
    localparam UART_ERR_ADDR = 32'h1000_000C;  // Read: Error status
    
    //----------------------------
    // CPU Instance
    //----------------------------
    kianv_cpu cpu_inst (
        .clk        (clk),
        .resetn     (resetn),
        .mem_addr   (cpu_mem_addr),
        .mem_wdata  (cpu_mem_wdata),
        .mem_rdata  (cpu_mem_rdata),
        .mem_wr     (cpu_mem_wr),
        .mem_rd     (cpu_mem_rd)
    );
    
    //----------------------------
    // Merged UART Instance
    //----------------------------
    uart #(
        .SYSTEM_CLK (SYSTEM_CLK),
        .BAUDRATE   (BAUDRATE)
    ) uart_inst (
        .clk       (clk),
        .resetn    (resetn),
        // TX interface
        .tx_valid  (uart_tx_valid),
        .tx_data   (cpu_mem_wdata[7:0]),
        .tx_ready  (uart_tx_ready),
        .tx_out    (uart_tx),
        // RX interface
        .rx_pop    (uart_rx_pop),
        .rx_in     (uart_rx),
        .rx_data   (uart_rx_data),
        .rx_valid  (uart_rx_valid),
        .rx_error  (uart_rx_error)
    );
    
    //----------------------------
    // Memory-Mapped Register Logic
    //----------------------------
    reg [31:0] mem_rdata_reg;
    assign cpu_mem_rdata = mem_rdata_reg;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            mem_rdata_reg <= 32'd0;
        end else begin
            mem_rdata_reg <= 32'd0;  // Default value
            
            if (cpu_mem_rd) begin
                case (cpu_mem_addr)
                    UART_RX_ADDR:  mem_rdata_reg <= {24'd0, uart_rx_data};
                    UART_LSR_ADDR: mem_rdata_reg <= {29'd0, uart_rx_error, uart_rx_valid, uart_tx_ready};
                    UART_ERR_ADDR: mem_rdata_reg <= {31'd0, uart_rx_error};
                    default:       mem_rdata_reg <= 32'd0;
                endcase
            end
        end
    end
    
    //----------------------------
    // Control Signal Generation
    //----------------------------
    assign uart_tx_valid = (cpu_mem_wr && cpu_mem_addr == UART_TX_ADDR);
    assign uart_rx_pop   = (cpu_mem_rd && cpu_mem_addr == UART_RX_ADDR);

endmodule