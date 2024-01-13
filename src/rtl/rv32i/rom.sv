`ifndef __RV32I_ROM_SV
`define __RV32I_ROM_SV

`include "rv32i/rv32i.sv" 

module rom import rv32i::*;
(
    input logic clk,
    input logic [31:0] addr,
    output logic [31:0] data
);

  logic [31:0] inner_rom [0:1023]/*verilator public*/; // 4KB
  logic [9:0] inner_addr;

  // // for test
  // initial begin
  //   $readmemh ("rom.txt", rom);
  //   // foreach (rom[i]) $display("readmemb : %08b", rom[i]);
  // end

  always_ff @(posedge clk) begin
    inner_addr <= addr[11:2];
  end
  assign data = inner_rom[inner_addr];
endmodule

`endif