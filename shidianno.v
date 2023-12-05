`timescale 1ns / 1ps



//...................................................................................................
//..................................................................................................
//SHIDIANNO  



 module buffer #(
    parameter ADDR_BITS_MB = 10,
    parameter DATA_BITS_MB = 16
)(
    input wire clk,
    input wire reset,
    input wire [ADDR_BITS_MB-1:0] addr_in_mb,
    input wire [DATA_BITS_MB-1:0] data_in_mb,
    input wire write_enable_mb,
    input wire [1:0] read_control, // Control signal to select read addresses
    output reg [DATA_BITS_MB-1:0] data_out1_mb,
    output reg [DATA_BITS_MB-1:0] data_out2_mb,
    output reg [DATA_BITS_MB-1:0] data_out3_mb
);

    // Define internal memory for SPAD
    reg [DATA_BITS_MB-1:0] memory_mb [0:(1 << ADDR_BITS_MB) - 1];
    integer i_mb;

    // Read and Write Operations
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset memory (initialize to zero)
            for (i_mb = 0; i_mb < (1 << ADDR_BITS_MB); i_mb = i_mb + 1) begin
                memory_mb[i_mb] <= 0; // Set memory contents to zero during reset
            end
        end else begin
            if (write_enable_mb) begin
                // Write operation to SPAD at addr_in_mb
                memory_mb[addr_in_mb] <= data_in_mb;
            end

            // Read operations from SPAD based on read_control signal
            case (read_control)
                2'b00: begin
                    data_out1_mb <= memory_mb[addr_in_mb]; // Read from addr_in_mb for data_out1_mb
                end
                2'b01: begin
                    data_out2_mb <= memory_mb[addr_in_mb]; // Read from addr_in_mb for data_out2_mb
                end
                2'b10: begin
                    data_out3_mb <= memory_mb[addr_in_mb]; // Read from addr_in_mb for data_out3_mb
                end
                default: begin
                    // Default case
                    data_out1_mb <= memory_mb[addr_in_mb]; // Read from addr_in_mb for data_out1_mb
                end
            endcase
        end
    end

endmodule


module shidiano ( );

wire dummy_clock;
wire dummy_reset;
wire [1:0] dummy_read_control;
wire [1:0] in_row[2:0][2:0];
wire [1:0] d_in[2:0][2:0];
wire [1:0] r_in[2:0][2:0];
wire [1:0] k_in[2:0][2:0];
wire pe_mb_enable[2:0][2:0];
wire [1:0] pe_out[2:0][2:0];
wire [1:0] out[2:0][2:0];

  parameter ADDR_BITS_buffer = 8; 
  parameter DATA_BITS_buffer = 6;
  
 wire [1:0] kernel_in;
buffer #(.ADDR_BITS_MB(ADDR_BITS_buffer), .DATA_BITS_MB(DATA_BITS_buffer)) Buffer_controller (
    .clk(dummy_clock),
    .reset(dummy_reset),
    .addr_in_mb(buffer_addr),
    .data_in_mb(buffer_data_in),
    .write_enable_mb(buffer_enable),
    .read_control(dummy_read_control),
    .data_out1_mb(input_col),
    .data_out2_mb(input_row),
    .data_out3_mb(kernel_in)
  );
  
  pe_mb PE_unit[2:0][2:0] (
  .clock(dummy_clock),
  .input_row(in_row),
  .kernel(k_in),
  .down_in(d_in),
  .right_in(r_in),
  .pe_enable(pe_mb_enable),
  .pe_output(pe_out),
  .fixed_out(out)
  );
 genvar i,j,a,b;
  generate
  for( j=0;j<3 ;j++)begin 
  assign pe_out[1][j] = d_in[0][j] ;
  assign pe_out[2][j] = d_in[1][j] ;
  assign pe_out[0][j] = d_in[2][j] ;
end

   for( i=0;i<3 ;i++)begin
  assign pe_out[i][2] = r_in[i][1] ;
  assign pe_out[i][1] = r_in[i][0] ;
  assign input_col = r_in[i][2];
end

  for (a=0; a<3; a++)begin
   for(b=0;b<3;b++)begin
   assign input_row = in_row[a][b];
   assign kernel_in = k_in[a][b];
      end
  end
endgenerate
  
endmodule
  
module pe_mb(
   input wire clock,
  input wire [1:0] input_row,
  input wire [1:0] kernel,
  input wire [1:0] down_in,
  input wire [1:0] right_in,  
  input wire pe_enable,
  output reg [1:0] pe_output,
  output reg [1:0] fixed_out
  );
   
  endmodule
