`include "rv32i/rv32i.sv" 

module ram import rv32i::*;
(
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input mem_op_e mem_op,
    output logic [31:0] rdata
);

  logic [31:0] rom [0:1023]; // 4KB
  logic [9:0] inner_addr;
  assign inner_addr = addr[11:2];
  always_ff @(posedge clk) begin
    if (mem_op == MEM_STORE) begin
      rom[inner_addr] <= wdata;
      rdata <= wdata;
    end else begin
      rdata <= rom[inner_addr];
    end
  end
endmodule
