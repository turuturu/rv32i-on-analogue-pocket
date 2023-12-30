`include "define.sv" 


module decoder 
(
  input  logic [31:0]instr, // instruction
  output logic [4:0] rs1,   // source register 1
  output logic [4:0] rs2,   // source register 2
  output logic [4:0] rd,    // destination register
  output logic [31:0] imm,  // immediate
  output rv_op_e rv_op    // ALU operation
);
  opcode_e opcode;
  optype_e optype;

  logic [2:0] funct3;
  logic [6:0] funct7;

  assign opcode = opcode_e'(instr[6:0]);
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];

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
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        rd = instr[11:7];
        imm = 32'b0;
      end
      ITYPE: begin
        rs1 = instr[19:15];
        rs2 = 5'b0;
        rd = instr[11:7];
        imm = {{20{instr[31]}}, instr[31:20]};
      end
      STYPE: begin
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        rd = 5'b0;
        imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      end
      BTYPE: begin
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        rd = 5'b0;
        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      end
      UTYPE: begin
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = instr[11:7];
        imm = {instr[31:12], 12'b0};
      end
      JTYPE: begin
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = instr[11:7];
        imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      end
      default: begin
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = 5'b0;
        imm = 32'b0;
      end
    endcase
  end

endmodule
