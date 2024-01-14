`ifndef __RV32I_CSR_REGISTERS_SV
`define __RV32I_CSR_REGISTERS_SV

`include "rv32i/rv32i.sv" 

module csr_registers import rv32i::*;
(
    input logic clk,
    input reg_we_e we,
    input logic [11:0] csr_addr,
    input logic [31:0] wdata,
    ouput logic [31:0] data
);
  logic [31:0] regs [0:4096]/*verilator public*/; // 16KB = 12bit address range

  always_ff @(posedge clk) begin
    if (we == REG_WE) begin
      regs[csr_addr] <= rd_data;
    end
  end

  assign data = regs[csr_addr];

endmodule

`endif