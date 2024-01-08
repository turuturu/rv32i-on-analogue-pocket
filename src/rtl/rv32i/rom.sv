`include "rv32i/rv32i.sv" 

module rom import rv32i::*;
(
    input logic clk,
    input logic [31:0] addr,
    output logic [31:0] data
);

  logic [31:0] rom [0:1023]; // 4KB
  logic [9:0] inner_addr;

  // for test
  initial begin
    $readmemh ("rom.txt", rom);
  end

  always_ff @(posedge clk) begin
    inner_addr <= addr[11:2];
  end
  assign data = rom[inner_addr];
endmodule
