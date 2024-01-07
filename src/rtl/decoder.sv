`include "define.sv" 

module decoder 
(
//  input  logic [31:0] instr, // instruction
  input  rv32i_inst_u instr, // instruction
  output logic [4:0] rs1,   // source register 1
  output logic [4:0] rs2,   // source register 2
  output logic [4:0] rd,    // destination register
  output logic [31:0] imm,  // immediate
  output logic r_we,        // register write enable
  output rv_op_e rv_op    // ALU operation
);
  opcode_e opcode;
  optype_e optype;

  logic [2:0] funct3;
  logic [6:0] funct7;

  assign r_we = 1;

  always_comb begin
    unique case (opcode)
      LUI: begin
        optype = UTYPE;
        rv_op = RV_LUI;
      end
      AUIPC: begin
        optype = UTYPE;
        rv_op = RV_LUI;
      end
      default: begin
        optype = UTYPE;
        rv_op = RV_BGEU;
      end
    endcase
  end
  always_comb begin
    unique case (optype)
      RTYPE: begin
        funct3 = instr.type_r.funct3;
        funct7 = instr.type_r.funct7;
        rs1 = instr.type_r.rs1;
        rs2 = instr.type_r.rs2;
        rd = instr.type_r.rd;
        imm = 32'b0;
        opcode = instr.type_r.opcode;
      end
      ITYPE: begin
        funct3 = instr.type_i.funct3;
        funct7 = 7'b0;
        rs1 = instr.type_i.rs1;
        rs2 = 5'b0;
        rd = instr.type_i.rd;
        imm = {{20{instr.type_i.imm[11]}}, instr.type_i.imm};
        opcode = instr.type_i.opcode;
      end
      STYPE: begin
        funct3 = instr.type_s.funct3;
        funct7 = 7'b0;
        rs1 = instr.type_s.rs1;
        rs2 = instr.type_s.rs2;
        rd = 5'b0;
        imm = {{20{instr.type_s.imm1[6]}}, instr.type_s.imm1[6:0], instr.type_s.imm2[0:4]};
        opcode = instr.type_s.opcode;
      end
      BTYPE: begin
        funct3 = instr.type_b.funct3;
        funct7 = 7'b0;
        rs1 = instr.type_b.rs1;
        rs2 = instr.type_b.rs2;
        rd = 5'b0;
        imm = {{19{instr.type_b.imm1[6]}}, instr.type_b.imm1[6], instr.type_b.imm2[0], instr.type_b.imm1[5:0], instr.type_b.imm2[4:1], 1'b0};
        opcode = instr.type_b.opcode;
      end
      UTYPE: begin
        funct3 = 3'b0;
        funct7 = 7'b0;
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = instr.type_u.rd;
        imm = {instr.type_u.imm, 12'b0};
        opcode = instr.type_u.opcode;
      end
      JTYPE: begin
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = instr.type_u.rd;
        imm = {{11{instr.type_j.imm[19]}}, instr.type_j.imm[19], instr.type_j.imm[7:0], instr.type_j.imm[8], instr.type_j.imm[18:9], 1'b0};
        opcode = instr.type_j.opcode;
      end
      default: begin
        funct3 = 3'b0;
        funct7 = 7'b0;
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = 5'b0;
        imm = 32'b0;
        opcode = 7'b0;
      end
    endcase
  end

endmodule
