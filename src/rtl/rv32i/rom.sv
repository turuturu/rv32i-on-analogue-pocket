`ifndef __RV32I_ROM_SV
`define __RV32I_ROM_SV

`include "rv32i/rv32i.sv" 

module rom import rv32i::*;
#(
  parameter ADDR_LENGTH = 10, // 4KB
  parameter DELAY = 0,
  // parameter ADDR_LENGTH = 8, // 1KB
  parameter MEM_SIZE = 2**ADDR_LENGTH
)
(
    input logic clk,
    input logic [31:0] addr,
    input logic re,
    output logic [31:0] data,
    output logic oe
);

  // logic [31:0] inner_rom [0:MEM_SIZE-1]/*verilator public*/; // 16KB
  (* ramstyle = "MLAB" *)logic [31:0] inner_rom [0:MEM_SIZE-1]/*verilator public*/;
  // logic [31:0] inner_rom [0:255]/*verilator public*/; // 1KB
  logic [ADDR_LENGTH-1:0] inner_addr;
  logic [2:0] counter = 0;
  // // for test
  // initial begin
  //   $readmemh ("rom.txt", rom);
  //   // foreach (rom[i]) $display("readmemb : %08b", rom[i]);
  // end

  always_ff @(posedge clk) begin
    inner_addr <= (counter == 0 & re) ? addr[ADDR_LENGTH+1:2] : inner_addr;
    counter <= DELAY == 0 ? 0 : 
              (counter == 0 & re) ? 0 :
              (counter == 0 | counter == DELAY) ? 0 :
              counter + 1;
    oe <= counter == DELAY;
  end
  assign data = inner_rom[inner_addr];
endmodule

`endif