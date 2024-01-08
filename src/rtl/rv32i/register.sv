`include "rv32i/rv32i.sv" 

module registers import rv32i::*;
(
    input logic clk,
    input reg_we_e we,
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic [4:0] rd_addr,
    input logic [31:0] rd_data,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
);
  logic [31:0] regs [0:31];

  always_ff @(posedge clk) begin
    if (we == REG_WE) begin
      regs[rd_addr] <= rd_data;
    end
  end

  assign rs1_data = rs1_addr == 5'b0 ? 32'b0 : regs[rs1_addr];
  assign rs2_data = rs2_addr == 5'b0 ? 32'b0 : regs[rs2_addr];

endmodule