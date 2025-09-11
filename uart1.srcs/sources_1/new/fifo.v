`default_nettype none
`timescale 1ns / 1ps

module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
) (
    input  wire                    clk,
    input  wire                    resetn,
    input  wire [DATA_WIDTH-1:0]   din,
    output wire [DATA_WIDTH-1:0]   dout,
    input  wire                    push,
    input  wire                    pop,
    output wire                    full,
    output wire                    empty
);

    // safe clog2 function
    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = value - 1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    localparam PTR_WIDTH = (DEPTH > 1) ? clog2(DEPTH) : 1;

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [PTR_WIDTH:0]    cnt;
    reg [PTR_WIDTH-1:0]  rd_ptr, wr_ptr;

    assign empty = (cnt == 0);
    assign full  = (cnt == DEPTH);
    assign dout  = mem[rd_ptr];

    // synchronous pointer and count update
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
            cnt    <= 0;
        end else begin
            // write
            if (push && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
            end

            // read pointer advance
            if (pop && !empty) begin
                rd_ptr <= rd_ptr + 1;
            end

            // count update (one-hot logic)
            case ({push && !full, pop && !empty})
                2'b10: cnt <= cnt + 1;
                2'b01: cnt <= cnt - 1;
                default: cnt <= cnt;
            endcase
        end
    end

endmodule
