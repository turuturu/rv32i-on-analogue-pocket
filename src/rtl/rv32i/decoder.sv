`ifndef __RV32I_DECODER_SV
`define __RV32I_DECODER_SV

`include "rv32i/rv32i.sv" 

module decoder import rv32i::*;
(
  input  rv32i_inst_u instr,                     // instruction
  output logic [4:0] rs1,                        // source register 1
  output logic [4:0] rs2,                        // source register 2
  output logic [4:0] rd,                         // destination register
  output logic [31:0] imm,                       // immediate
  output alu_op_e alu_op,                        // ALU operation
  output alu_input1_type_e alu_input1_type,       // ALU OPTYPE 1
  output alu_input2_type_e alu_input2_type,       // ALU OPTYPE 1
  output wb_from_e wb_from,                      // write back from
  output reg_we_e r_we,                          // register write enable
  output mem_op_e mem_op,                        // memory write enable
  output reg_we_e csr_we                         // CSR write enable
);
  opcode_e opcode;
  optype_e optype/*verilator public*/;

  assign opcode = opcode_e'(instr[6:0]);

  always_comb begin
    unique case (opcode)
      OP_LUI: begin
        optype = UTYPE;
        alu_op = ALU_ADD;
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = instr.type_u.rd;
        alu_input1_type = ALU_INPUT1_IMM;
        alu_input2_type = ALU_INPUT2_NONE;
        wb_from = WB_ALU;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = {instr.type_u.imm, 12'b0};
        csr_we = REG_WD;
      end
      OP_AUIPC: begin
        optype = UTYPE;
        alu_op = ALU_ADD;
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = instr.type_u.rd;
        alu_input1_type = ALU_INPUT1_PC;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_ALU;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = {instr.type_u.imm, 12'b0};
        csr_we = REG_WD;
      end
      OP_JAL: begin
        optype = JTYPE;
        alu_op = ALU_JAL;
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = instr.type_j.rd;
        alu_input1_type = ALU_INPUT1_PC;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_PC;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = {{11{instr.type_j.imm[19]}}, instr.type_j.imm[19], instr.type_j.imm[7:0], instr.type_j.imm[8], instr.type_j.imm[18:9], 1'b0};
        csr_we = REG_WD;
      end
      OP_JALR: begin
        optype = ITYPE;
        alu_op = ALU_JALR;
        rs1 = instr.type_i.rs1;
        rs2 = 5'b0;
        rd = instr.type_i.rd;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_PC;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = {{20{instr.type_i.imm[11]}}, instr.type_i.imm};
        csr_we = REG_WD;
      end
      OP_BRANCH: begin
        optype = BTYPE;
        rs1 = instr.type_b.rs1;
        rs2 = instr.type_b.rs2;
        rd = 5'b0;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_RS2;
        wb_from = WB_NONE;
        r_we = REG_WD;
        mem_op = MEM_LOAD;
        imm = {{19{instr.type_b.imm1[6]}}, instr.type_b.imm1[6], instr.type_b.imm2[0], instr.type_b.imm1[5:0], instr.type_b.imm2[4:1], 1'b0};
        csr_we = REG_WD;
        case (instr.type_b.funct3)
          3'b000: begin // BEQ
            alu_op = ALU_BEQ;
          end
          3'b001: begin // BNE
            alu_op = ALU_BNE;
          end
          3'b100: begin // BLT
            alu_op = ALU_BLT;
          end
          3'b101: begin // BGE
            alu_op = ALU_BGE;
          end
          3'b110: begin // BLTU
            alu_op = ALU_BLTU;
          end
          3'b111: begin // BGEU
            alu_op = ALU_BGEU;
          end
          default: begin
            // never happens
            alu_op = ALU_NOP;
          end
        endcase
      end
      OP_LOAD: begin
        optype = ITYPE;
        rs1 = instr.type_i.rs1;
        rs2 = 5'b0;
        rd = instr.type_i.rd;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_MEM;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = {{20{instr.type_i.imm[11]}}, instr.type_i.imm};
        csr_we = REG_WD;
        case (instr.type_i.funct3)
          3'b000: begin // LB
            alu_op = ALU_ADD;
          end
          3'b001: begin // LH
            alu_op = ALU_ADD;
          end
          3'b010: begin // LW
            alu_op = ALU_ADD;
          end
          3'b100: begin // LBU
            alu_op = ALU_ADD;
          end
          3'b101: begin // LHU
            alu_op = ALU_ADD;
          end
          default: begin
            // never happens
            alu_op = ALU_NOP;
          end
        endcase
      end
      OP_STORE: begin
        optype = STYPE;
        rs1 = instr.type_s.rs1;
        rs2 = instr.type_s.rs2;
        rd = 5'b0;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_NONE;
        r_we = REG_WD;
        mem_op = MEM_STORE;
        imm = {{20{instr.type_s.imm1[6]}}, instr.type_s.imm1[6:0], instr.type_s.imm2[4:0]};
        csr_we = REG_WD;
        case (instr.type_s.funct3)
          3'b000: begin // SB
            alu_op = ALU_ADD;
          end
          3'b001: begin // SH
            alu_op = ALU_ADD;
          end
          3'b010: begin // SW
            alu_op = ALU_ADD;
          end
          default: begin
            // never happens
            alu_op = ALU_NOP;
          end
        endcase
      end
      OP_OPIMM: begin
        optype = ITYPE;
        rs1 = instr.type_i.rs1;
        rs2 = 5'b0;
        rd = instr.type_i.rd;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_ALU;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = {{20{instr.type_i.imm[11]}}, instr.type_i.imm};
        csr_we = REG_WD;
        unique case (instr.type_i.funct3)
          3'b000: begin // ADDI
            alu_op = ALU_ADD;
          end
          3'b010: begin // SLTI
            alu_op = ALU_SLT;
          end
          3'b011: begin // SLTIU
            alu_op = ALU_SLTU;
          end
          3'b100: begin // XORI
            alu_op = ALU_XOR;
          end
          3'b110: begin // ORI
            alu_op = ALU_OR;
          end
          3'b111: begin // ANDI
            alu_op = ALU_AND;
          end
          3'b001: begin // SLLI
            alu_op = ALU_SLL;
          end
          3'b101: begin // SRLI, SRAI
            if (instr.type_i.imm[11:5] == 7'b0000000) begin
              alu_op = ALU_SRL;
            end else begin
              alu_op = ALU_SRA;
            end
          end
          default: begin
            // never happens
            alu_op = ALU_NOP;
          end

        endcase
      end
      OP_OP: begin
        optype = RTYPE;
        rs1 = instr.type_r.rs1;
        rs2 = instr.type_r.rs2;
        rd = instr.type_r.rd;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_RS2;
        wb_from = WB_ALU;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = 32'b0;
        csr_we = REG_WD;
        unique case (instr.type_r.funct3)
          3'b000: begin // ADD, SUB
            if (instr.type_r.funct7 == 7'b0000000) begin
              alu_op = ALU_ADD;
            end else begin
              alu_op = ALU_SUB;
            end
          end
          3'b001: begin // SLL
            alu_op = ALU_SLL;
          end
          3'b010: begin // SLT
            alu_op = ALU_SLT;
          end
          3'b011: begin // SLTU
            alu_op = ALU_SLTU;
          end
          3'b100: begin // XOR
            alu_op = ALU_XOR;
          end
          3'b101: begin // SRL, SRA
            if (instr.type_r.funct7 == 7'b0000000) begin
              alu_op = ALU_SRL;
            end else begin
              alu_op = ALU_SRA;
            end
          end
          3'b110: begin // OR
            alu_op = ALU_OR;
          end
          3'b111: begin // AND
            alu_op = ALU_AND;
          end
        endcase
      end
      OP_FENCE: begin
        optype = ITYPE;
        alu_op = ALU_NOP;
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = 5'b0;
        alu_input1_type = ALU_INPUT1_NONE;
        alu_input2_type = ALU_INPUT2_NONE;
        wb_from = WB_NONE;
        r_we = REG_WD;
        mem_op = MEM_LOAD;
        imm = 32'b0;
        csr_we = REG_WD;
        // if (instr.type_i.funct3 == 3'b000) begin // FENCE
        //   csr_op = CSR_NOP;
        // end else begin // FENCE.I
        //   csr_op = CSR_NOP;
        // end
      end
      OP_SYSTEM: begin
        optype = ITYPE;
        rs1 = instr.type_i.rs1;
        rs2 = 5'b0;
        rd = instr.type_i.rd;
        mem_op = MEM_LOAD;
        imm = {20'b0, instr.type_i.imm};
        unique case (instr.type_i.funct3)
          3'b000: begin
            // if (instr.type_i.imm == 12'b000000000000) begin // ECALL
            //   csr_op = CSR_NOP;
            // end else begin // EBREAK
            //   csr_op = CSR_NOP;
            // end
            alu_op = ALU_NOP;
            alu_input1_type = ALU_INPUT1_NONE;
            alu_input2_type = ALU_INPUT2_NONE;
            wb_from = WB_NONE;
            r_we = REG_WD;
            csr_we = REG_WD;
          end
          3'b001: begin // CSRRW
            alu_op = ALU_ADD;
            alu_input1_type = ALU_INPUT1_RS1;
            alu_input2_type = ALU_INPUT2_NONE;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b010: begin // CSRRS
            alu_op = ALU_OR;
            alu_input1_type = ALU_INPUT1_CSR;
            alu_input2_type = ALU_INPUT2_RS1;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b011: begin // CSRRC
            alu_op = ALU_CSRRC;
            alu_input1_type = ALU_INPUT1_CSR;
            alu_input2_type = ALU_INPUT2_RS1;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b101: begin // CSRRWI
            alu_op = ALU_ADD;
            alu_input1_type = ALU_INPUT1_IMM;
            alu_input2_type = ALU_INPUT2_NONE;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b110: begin // CSRRSI
            alu_op = ALU_OR;
            alu_input1_type = ALU_INPUT1_CSR;
            alu_input2_type = ALU_INPUT2_IMM;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b111: begin // CSRRCI
            alu_op = ALU_CSRRC;
            alu_input1_type = ALU_INPUT1_CSR;
            alu_input2_type = ALU_INPUT2_RS1;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          default: begin
            alu_op = ALU_NOP;
            alu_input1_type = ALU_INPUT1_NONE;
            alu_input2_type = ALU_INPUT2_NONE;
            // never happens
            wb_from = WB_NONE;
            r_we = REG_WD;
            csr_we = REG_WD;
          end
        endcase
      end
      default: begin
        optype = ITYPE;
        alu_op = ALU_NOP;
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = 5'b0;
        alu_input1_type = ALU_INPUT1_NONE;
        alu_input2_type = ALU_INPUT2_NONE;
        wb_from = WB_NONE;
        r_we = REG_WD;
        csr_we = REG_WD;
        mem_op = MEM_LOAD;
        imm = 32'b0;
      end
    endcase
  end
endmodule

`endif