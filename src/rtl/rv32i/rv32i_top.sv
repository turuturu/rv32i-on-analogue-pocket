`ifndef __RV32I_RV32I_TOP_SV
`define __RV32I_RV32I_TOP_SV

`include "rv32i/rv32i.sv"
`include "rv32i/alu.sv"
`include "rv32i/csr_alu.sv"
`include "rv32i/csr_registers.sv"
`include "rv32i/decoder.sv"
`include "rv32i/ram.sv"
`include "rv32i/registers.sv"
`include "rv32i/rom.sv"

module rv32i_top import rv32i::*;
(
    input logic clk,
    input logic reset_n
);
  logic [31:0] pc;
  logic [31:0] next_pc;

  rv32i_inst_u instr;                      // instruction
  logic [4:0] rs1;                         // source register 1
  logic [4:0] rs2;                         // source register 2
  logic [4:0] rd;                          // destination register
  logic [31:0] imm;                        // immediate
  alu_op_e alu_op;                         // ALU operation
  alu_input_type_e alu_input1_type;        // ALU OPTYPE 1
  alu_input_type_e alu_input2_type;        // ALU OPTYPE 1
  wb_from_e wb_from;                       // write back from
  reg_we_e r_we;                           // register write enable
  mem_op_e mem_op;                         // memory write enable
  branch_type_e branch_type;               // branch type
  csr_op_e csr_op;                         // CSR operation
  reg_we_e csr_we;                         // CSR write enable
  logic [11:0] csr_addr;                   // CSR address
  csr_alu_input_type_e csr_alu_input_type; // CSR ALU input type

  logic [31:0] rs1_data; // rs1 output
  logic [31:0] rs2_data; // rs2 output
  logic [31:0] csr_data; // csr alu result
  logic [31:0] alu_input1; // alu input 1
  logic [31:0] alu_input2; // alu input 2
  logic [31:0] alu_result; // alu result
  logic [31:0] csr_alu_result; // csr alu result
  logic [31:0] csr_alu_input; // csr alu input

  logic [31:0] ram_out; // ram output
  logic [31:0] reg_wb; // register write back

  assign next_pc = branch_type == BRANCH_RELATIVE ? pc + 4 + imm :
                  branch_type == BRANCH_ABSOLUTE ? alu_result :
                  pc + 4;

  assign alu_input1 = alu_input1_type == ALU_INPUT_IMM ? imm :
                      alu_input1_type == ALU_INPUT_REG ? rs1_data : 
                      alu_input1_type == ALU_INPUT_PC ? pc : 
                      32'b0;
  assign alu_input2 = alu_input2_type == ALU_INPUT_IMM ? imm :
                      alu_input2_type == ALU_INPUT_REG ? rs2_data : 
                      alu_input2_type == ALU_INPUT_PC ? pc : 
                      32'b0;

  assign reg_wb = wb_from == WB_ALU ? alu_result :
                  wb_from == WB_PC ? next_pc :
                  wb_from == WB_MEM ? ram_out :
                  32'b0;

  assign csr_alu_input = csr_alu_input_type == CSR_ALU_INPUT_IMM ? {27'b0, rs1} :
                     csr_alu_input_type == CSR_ALU_INPUT_RS1 ? rs1_data :
                     32'b0;

  assign csr_addr = csr_alu_input_type == CSR_ALU_INPUT_NONE ? 12'b0 :
                    imm[11:0];

  always_ff @(posedge clk or reset_n) begin
    if (reset_n == 0) begin
      pc <= 32'h8000_0000;
    end else begin
      pc <= next_pc;
    end
  end

  rom rom0 (
    // -- Inputs
    .clk,
    .addr(pc),
    // -- Outputs
    .data(instr)
  );
  decoder decoder0 (
    // -- Inputs
    .instr,
    // -- Outputs
    .rs1,
    .rs2,
    .rd,
    .imm,
    .alu_op,
    .alu_input1_type,
    .alu_input2_type,
    .wb_from,
    .r_we,
    .mem_op,
    .csr_op,
    .csr_we,
    .csr_alu_input_type
  );

  registers registers0 (
    // -- Inputs
    .clk,
    .we(r_we),
    .rs1_addr(rs1),
    .rs2_addr(rs2),
    .rd_addr(rd),
    .rd_data(alu_result),
    // -- Outputs
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
  );

  csr_registers csr_registers0 (
    // -- Inputs
    .clk,
    .we(csr_we),
    .csr_addr(csr_addr),
    .wdata(csr_alu_result),
    // -- Outputs
    .data(csr_data)
  );

  alu alu0 (
    // -- Inputs
    .data1(alu_input1),
    .data2(alu_input2),
    .alu_op(alu_op),
    // -- Outputs
    .result(alu_result),
    .branch_type(branch_type)
  );

  csr_alu csr_alu0 (
    // -- Inputs
    .csr_data(csr_data),
    .data(csr_alu_input),
    .csr_op(csr_op),
    // -- Outputs
    .result(csr_alu_result)
  );

  ram ram0 (
    // -- Inputs
    .clk,
    .addr(alu_result),
    .wdata(rs2_data),
    .mem_op(mem_op),
    // -- Outputs
    .rdata(ram_out)
  );
endmodule

`endif