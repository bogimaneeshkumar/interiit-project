`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2023 16:58:44
// Design Name: 
// Module Name: edgeDRnn
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module edgeDRnn(   );

wire dummy_clock;
wire dummy_rst;
wire dummy_enable;
wire [15:0] Del_St;
wire [15:0] D_fifo;
wire [15:0] PE_out;
wire [15:0] H_out;
wire [15:0] Pcol;
wire [15:0] Inst;
wire [15:0] W_in;
wire [15:0] W_out;
wire [15:0] X_in;
wire [15:0] delta_H;


FIFO #( .DATA_WIDTH(16), .DEPTH(16) ) D_FIFO(
.clk(dummy_clock),
.rst(dummy_rst),
.wr_en(dummy_enable),
.rd_en(dummy_enable),
.full(dummy_full),
.empty(dummy_empty),
.data_in(Del_St),
.data_out(D_fifo)
);

FIFO #( .DATA_WIDTH(16), .DEPTH(16) ) W_FIFO(
.clk(dummy_clock),
.rst(dummy_rst),
.wr_en(dummy_enable),
.rd_en(dummy_enable),
.full(dummy_full),
.empty(dummy_empty),
.data_in(W_in),
.data_out(W_out)
);

PE_Array pe_array(
.H_in(delta_H),
.H_out(PE_out),
.W(W_out),
.delta_St(D_fifo)
);

CTRL ctrl(
.pcol(Pcol),
.INST(Inst)
);

 Buffer #( .ADDR_BITS(8), .DATA_BITS(16)) OBUF(
 .clk(dummy_clock),
   .reset(dummy_rst),
    .addr_in(dummy_addr_in),
    .write_enable(dummy_enable),
    .data_in(PE_out),
    .data_out(H_out)
 
);

delta_unit Delta_Unit(
.valid(dummy_valid),
.conf(dummy_conf),
.Xt(X_in),
.H_in(H_out),
.ready(dummy_ready),
.H_out(delta_H),
.Dfifo(Del_St),
.ctrl(Pcol)
);


endmodule

module FIFO #(parameter DATA_WIDTH = 16 ,DEPTH = 16 ) (
  input wire clk,         // Clock signal
  input wire rst,         // Reset signal
  input wire wr_en,       // Write enable signal
  input wire rd_en,       // Read enable signal
  input wire [DATA_WIDTH-1:0] data_in,  // Input data
  output reg [DATA_WIDTH-1:0] data_out, // Output data
  output reg full,        // Full flag
  output reg empty        // Empty flag
);

  reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
  reg [$clog2(DEPTH):0] rd_ptr, wr_ptr;
  
  // Combinational logic for status flags
  assign full = ((wr_ptr + 1 == rd_ptr) || (wr_ptr + 1 == DEPTH && rd_ptr == 0)) ? 1'b1 : 1'b0;
  assign empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0;

  // Write operation
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      wr_ptr <= 0;
    end else begin
      if (wr_en && !full) begin
        fifo_mem[wr_ptr] <= data_in;
        wr_ptr <= (wr_ptr == DEPTH - 1) ? 0 : (wr_ptr + 1);
      end
    end
  end

  // Read operation
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      rd_ptr <= 0;
    end else begin
      if (rd_en && !empty) begin
        data_out <= fifo_mem[rd_ptr];
        rd_ptr <= (rd_ptr == DEPTH - 1) ? 0 : (rd_ptr + 1);
      end
    end
  end

endmodule


module delta_unit(
input wire [15:0] valid,
input wire [15:0] conf,
input wire [15:0] Xt,
input wire [15:0] H_in,
output reg [15:0] ready,
output reg [15:0] H_out,
output reg [15:0] Dfifo,
output reg [15:0] ctrl
);
endmodule

module PE_Array(
input wire [15:0] H_in,
input wire [15:0] W,
input wire [15:0] delta_St,
output reg [15:0] H_out
);
endmodule

module CTRL(
input wire [15:0] pcol,
output reg [15:0] INST
);
endmodule


module Buffer #(parameter ADDR_BITS = 8, DATA_BITS = 16) (
    input wire clk,
    input wire reset,
    input wire [ADDR_BITS-1:0] addr_in,
    input wire [DATA_BITS-1:0] data_in,
    input wire write_enable,
    output reg [DATA_BITS-1:0] data_out
);

// Define internal memory for Buffer
reg [DATA_BITS-1:0] memory [0:(1 << ADDR_BITS) - 1];
integer i;
// Read and Write Operations
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset memory (initialize to zero)
        for (i = 0; i < (1 << ADDR_BITS); i = i + 1) begin
            memory[i] <= 0; // Set memory contents to zero during reset
        end
    end else begin
        if (write_enable) begin
            // Write operation to Buffer
            memory[addr_in] <= data_in;
        end else begin
            // Read operation from Buffer
            data_out <= memory[addr_in];
        end
    end
end

endmodule
