`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.11.2023 20:30:01
// Design Name: eyeirss
// Module Name: top
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


module Eyeriss (
    // i/o Ports
);

parameter ADDR_BITS_GLB = 8; 
  parameter DATA_BITS_GLB = 6;
  
  wire [7:0] glb_addr;
  wire [5:0] glb_data_in ;
  wire [5:0] glb_data_out;
  
  wire dummy_clock; 
  memory_bank #(.ADDR_BITS(ADDR_BITS_GLB), .DATA_BITS(DATA_BITS_GLB)) glb_global_buffer (
    .clk(dummy_clock),
    .reset(dummy_reset),
    .addr_in(glb_addr),
    .data_in(glb_data_in),
    .write_enable(glb_write_enable),
    .data_out(glb_data_out)
  );
  
 
  wire [1:0] spad_data_in [2:0][2:0];
  wire [1:0] spad_data_out [2:0][2:0];



//pe - glb connection
  assign glb_data_out[1:0] =  spad_data_in[0][0];
  assign glb_data_out[3:2] = spad_data_in[0][1];
  assign glb_data_out[5:4] = spad_data_in[0][2];
  assign glb_data_in[1:0] =  spad_data_out[0][0];
  assign glb_data_in[3:2] = spad_data_out[0][1];
  assign glb_data_in[5:4] = spad_data_out[0][2];
    
  // PE Array
  pe_spad spads[2:0][2:0](
    .spad_in(spad_data_in), 
    .spad_out(spad_data_out)
  );
  
 assign spad_data_out[0][1] = spad_data_in[0][0];
 assign spad_data_out[0][0] = spad_data_in[0][1];
 assign spad_data_out[1][0] = spad_data_in[0][0];
 assign spad_data_out[0][0] = spad_data_in[1][0];
 assign spad_data_out[0][1] = spad_data_in[0][2];
 assign spad_data_out[0][2] = spad_data_in[0][1];
 assign spad_data_out[0][1] = spad_data_in[1][1];
 assign spad_data_out[1][1] = spad_data_in[0][1];
 assign spad_data_out[0][2] = spad_data_in[1][2];
 assign spad_data_out[1][2] = spad_data_in[0][2];
 assign spad_data_out[1][0] = spad_data_in[2][0];
 assign spad_data_out[2][0] = spad_data_in[1][0];
 assign spad_data_out[1][0] = spad_data_in[1][1];
 assign spad_data_out[1][1] = spad_data_in[1][0];
 assign spad_data_out[1][1] = spad_data_in[2][1];
 assign spad_data_out[2][1] = spad_data_in[1][1];
 assign spad_data_out[1][1] = spad_data_in[1][2];
 assign spad_data_out[1][2] = spad_data_in[1][1];
 assign spad_data_out[1][2] = spad_data_in[2][2];
 assign spad_data_out[2][2] = spad_data_in[1][2];
 assign spad_data_out[2][0] = spad_data_in[2][1];
 assign spad_data_out[2][1] = spad_data_in[2][0];
 assign spad_data_out[2][1] = spad_data_in[2][2];
 assign spad_data_out[2][2] = spad_data_in[2][1];
 

endmodule

module PE(
  input wire clock,
  input wire [1:0] pe_in,
  output reg spad_enable,
  output reg [1:0] pe_out
);


endmodule

module pe_spad( 

input wire [1:0]spad_in,
output reg [1:0]spad_out
);

wire spad_write_enable;
wire [2:0] spad_addr;
wire dummy_clock;


parameter ADDR_BITS_SPAD = 3;
  parameter DATA_BITS_SPAD = 2;
  // Instantiating the memory (SPAD)
  memory_bank #(.ADDR_BITS(ADDR_BITS_SPAD), .DATA_BITS(DATA_BITS_SPAD)) spad (
    .clk(dummy_clock),
    .reset(dummy_reset),
    .addr_in(spad_addr),
    .data_in(spad_in),
    .write_enable(spad_enable),
    .data_out(spad_out));
    
     PE dummy_PE (
          .clock(dummy_clock),
          .pe_in(spad_out),
          .pe_out(spad_in),
                .spad_enable (spad_write_enable)
        );
    
endmodule


module memory_bank #(parameter ADDR_BITS = 10, DATA_BITS = 16) (
    input wire clk,
    input wire reset,
    input wire [ADDR_BITS-1:0] addr_in,
    input wire [DATA_BITS-1:0] data_in,
    input wire write_enable, 
    output reg [DATA_BITS-1:0] data_out
);

// Define internal memory for SPAD
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
            // Write operation to SPAD
            memory[addr_in] <= data_in;
        end else begin
            // Read operation from SPAD
            data_out <= memory[addr_in];
        end
    end
end

endmodule
