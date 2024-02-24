`ifndef __RV32I_RAM_SV
`define __RV32I_RAM_SV

`include "rv32i/rv32i.sv" 

module ram import rv32i::*;
(
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input mem_op_e mem_op,
    output logic [31:0] rdata
);

  logic [31:0] inner_ram [0:4095]/*verilator public*/; // 4KB
  logic [11:0] inner_addr/*verilator public*/;
  always_ff @(posedge clk) begin
    if (mem_op == MEM_STORE) begin
      inner_ram[addr[13:2]] <= wdata;
    end
    inner_addr <= addr[13:2];
  end
  assign rdata = inner_ram[inner_addr];
endmodule

`endif