`ifndef __RV32I_ROM_SV
`define __RV32I_ROM_SV

`include "rv32i/rv32i.sv" 

module rom import rv32i::*;
#(
  parameter ADDR_LENGTH = 14, // 4KB
  // parameter DELAY = 5,
  parameter DELAY = 5,
  // parameter ADDR_LENGTH = 8, // 1KB
  parameter MEM_SIZE = 2**ADDR_LENGTH
)
(
    input logic clk,
    input logic [31:0] addr,
    input logic re,
    output logic [31:0] data[2**`CACHE_WORD_ADR_SIZE-1:0],
    output logic oe
);

  // logic [31:0] inner_rom [0:MEM_SIZE-1]/*verilator public*/; // 16KB
  (* ramstyle = "MLAB" *)logic [31:0] inner_rom [0:MEM_SIZE-1]/*verilator public*/;
  // logic [31:0] inner_rom [0:255]/*verilator public*/; // 1KB
  logic [ADDR_LENGTH-1:0] inner_addr/*verilator public*/;
  logic [2:0] counter = 0;
  // // for test
  // initial begin
  //   $readmemh ("rom.txt", rom);
  //   // foreach (rom[i]) $display("readmemb : %08b", rom[i]);
  // end

  always_ff @(posedge clk) begin
    inner_addr <= (counter == 0 & re) ? addr[ADDR_LENGTH+1:2] : inner_addr;
    counter <= DELAY == 0 ? 0 : 
              (counter == 0 & re) ? 1 :
              (counter == 0 | counter == DELAY) ? 0 :
              counter + 1;
    oe <= counter == DELAY;
    // for (int i = 0; i < 2**`CACHE_WORD_ADR_SIZE; i++) begin
    //   assign data[i] = inner_rom[inner_addr + i * 4];
    // end

  end
  // for (int i = 0; i < 8; i++) begin
  //   assign data[i] = inner_rom[inner_addr + i * 4];
  // end
  // assign data[0] = inner_rom[inner_addr];
  // assign data[1] = inner_rom[inner_addr+1];
  // assign data[2] = inner_rom[inner_addr+2];
  // assign data[3] = inner_rom[inner_addr+3];
  assign data[0] = inner_rom[{inner_addr[ADDR_LENGTH-1:`CACHE_WORD_ADR_SIZE],2'b00}];
  assign data[1] = inner_rom[{inner_addr[ADDR_LENGTH-1:`CACHE_WORD_ADR_SIZE],2'b01}];
  assign data[2] = inner_rom[{inner_addr[ADDR_LENGTH-1:`CACHE_WORD_ADR_SIZE],2'b10}];
  assign data[3] = inner_rom[{inner_addr[ADDR_LENGTH-1:`CACHE_WORD_ADR_SIZE],2'b11}];
endmodule

`endif
