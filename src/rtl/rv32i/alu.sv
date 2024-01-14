`ifndef __RV32I_ALU_SV
`define __RV32I_ALU_SV

`include "rv32i/rv32i.sv" 

module alu import rv32i::*;
(
    input logic [31:0] data1,
    input logic [31:0] data2,
    input alu_op_e alu_op,
    output logic [31:0] result,
    output branch_type_e branch_type
);

  logic signed [31:0] signed_data1;
  logic signed [31:0] signed_data2;
  assign signed_data1 = signed'(data1);
  assign signed_data2 = signed'(data2);

  always_comb begin
    case (alu_op)
      ALU_JAL: begin
        result = 32'b0;
        branch_type = BRANCH_RELATIVE;
      end
      ALU_JALR: begin
        result = (data1 + data2) & ~32'b1;
        branch_type = BRANCH_ABSOLUTE;
      end
      ALU_BEQ: begin
        result = 32'b0;
        branch_type = data1 == data2 ? BRANCH_RELATIVE : BRANCH_NONE;
      end
      ALU_BNE: begin
        result = 32'b0;
        branch_type = data1 != data2 ? BRANCH_RELATIVE : BRANCH_NONE;
      end
      ALU_BLT: begin
        result = 32'b0;
        branch_type = signed_data1 < signed_data2 ? BRANCH_RELATIVE : BRANCH_NONE;
      end
      ALU_BGE: begin
        result = 32'b0;
        branch_type = signed_data1 >= signed_data2 ? BRANCH_RELATIVE : BRANCH_NONE;
      end
      ALU_BLTU: begin
        result = 32'b0;
        branch_type = data1 < data2 ? BRANCH_RELATIVE : BRANCH_NONE;
      end
      ALU_BGEU: begin
        result = 32'b0;
        branch_type = data1 >= data2 ? BRANCH_RELATIVE : BRANCH_NONE;
      end
      ALU_ADD: begin
        result = data1 + data2;
        branch_type = BRANCH_NONE;
      end
      ALU_SUB: begin
        result = data1 - data2;
        branch_type = BRANCH_NONE;
      end
      ALU_SLL: begin
        result = data1 << data2[4:0];
        branch_type = BRANCH_NONE;
      end
      ALU_SLT: begin
        result = signed_data1 < signed_data2 ? 32'b1 : 32'b0;
        branch_type = BRANCH_NONE;
      end
      ALU_SLTU: begin
        result = data1 < data2 ? 32'b1 : 32'b0;
        branch_type = BRANCH_NONE;
      end
      ALU_XOR: begin
        result = data1 ^ data2;
        branch_type = BRANCH_NONE;
      end
      ALU_SRL: begin
        result = data1 >> data2[4:0];
        branch_type = BRANCH_NONE;
      end
      ALU_SRA: begin
        result = signed_data1 >>> data2[4:0];
        branch_type = BRANCH_NONE;
      end
      ALU_OR: begin
        result = data1 | data2;
        branch_type = BRANCH_NONE;
      end
      ALU_AND: begin
        result = data1 & data2;
        branch_type = BRANCH_NONE;
      end
      ALU_CSRRC: begin
        result = data1 & ~data2;
        branch_type = BRANCH_NONE;
      end
      ALU_NOP: begin
        result = 32'b0;
        branch_type = BRANCH_NONE;
      end
      default: begin
        result = 32'b0;
        branch_type = BRANCH_NONE;
      end
    endcase
  end

endmodule
`endif
