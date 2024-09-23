`ifndef __RV32I_CSR_REGISTERS_SV
`define __RV32I_CSR_REGISTERS_SV

`include "rv32i/rv32i.sv" 

module csr_registers import rv32i::*;
(
    input logic clk,
    input reg_we_e we,
    input logic [11:0] csr_addr,
    input logic [11:0] csr_waddr,
    input logic [31:0] wdata,
    output logic [31:0] data
);
  logic [31:0] regs [0:4095]/*verilator public*/; // 16KB = 12bit address range

  always_ff @(posedge clk) begin
    if (we == REG_WE) begin
      regs[csr_waddr] <= wdata;
    end
  end

  assign data = csr_addr == 12'h342 ? 32'hb : regs[csr_addr];

endmodule

`endif
