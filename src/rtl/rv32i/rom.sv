`ifndef __RV32I_ROM_SV
`define __RV32I_ROM_SV

`include "rv32i/rv32i.sv" 

module rom import rv32i::*;
#(
  // parameter ADDR_LENGTH = 12, // 16KB
  parameter ADDR_LENGTH = 8, // 1KB
  parameter MEM_SIZE = 2**ADDR_LENGTH
)
(
    input logic clk,
    input logic [31:0] addr,
    output logic [31:0] data
);

  logic [31:0] inner_rom [0:MEM_SIZE-1]/*verilator public*/; // 16KB
  // logic [31:0] inner_rom [0:255]/*verilator public*/; // 1KB
  logic [ADDR_LENGTH-1:0] inner_addr;

  // // for test
  // initial begin
  //   $readmemh ("rom.txt", rom);
  //   // foreach (rom[i]) $display("readmemb : %08b", rom[i]);
  // end

  always_ff @(posedge clk) begin
    inner_addr <= addr[ADDR_LENGTH+1:2];
  end
  assign data = inner_rom[inner_addr];
endmodule

`endif