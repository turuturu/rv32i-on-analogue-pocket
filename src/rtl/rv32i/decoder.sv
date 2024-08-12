`ifndef __RV32I_DECODER_SV
`define __RV32I_DECODER_SV

`include "rv32i/rv32i.sv" 

module decoder import rv32i::*;
(
  input  logic[31:0] instr,                     // instruction
  output logic [4:0] rs1,                        // source register 1
  output logic [4:0] rs2,                        // source register 2
  output logic [4:0] rd,                         // destination register
  output logic [31:0] imm,                       // immediate
  output alu_op_e alu_op,                        // ALU operation
  output pc_input_type_e pc_input_type,          // PC INPUT TYPE
  output alu_input1_type_e alu_input1_type,      // ALU INPUT TYPE 1
  output alu_input2_type_e alu_input2_type,      // ALU INPUT TYPE 2
  output wb_from_e wb_from,                      // write back from
  output reg_mask_e reg_mask,                    // reg mask
  output ram_mask_e ram_mask,                    // ram mask
  output reg_we_e r_we,                          // register write enable
  output mem_op_e mem_op,                        // memory write enable
  output reg_we_e csr_we                         // CSR write enable
);
  opcode_e opcode;
  optype_e optype/*verilator public*/;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:0] imm_i;
  logic [31:0] unsigned_imm_i;
  logic [31:0] imm_s;
  logic [31:0] imm_b;
  logic [31:0] imm_u;
  logic [31:0] imm_j;
  
  assign opcode = opcode_e'(instr[6:0]);
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
  assign rd = wb_from == WB_NONE ? 0 : instr[11:7];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];
  assign imm_i = {{20{instr[31]}}, instr[31:20]};
  assign unsigned_imm_i = {20'b0, instr[31:20]};

  assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
  assign imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        
  assign imm_u = {instr[31:12], 12'b0};
  assign imm_j =  {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

  always_comb begin
    unique case (opcode)
      OP_LUI: begin
        optype = UTYPE;
        alu_op = ALU_ADD;
        pc_input_type = PC_INPUT_NEXT;
        alu_input1_type = ALU_INPUT1_IMM;
        alu_input2_type = ALU_INPUT2_NONE;
        wb_from = WB_ALU;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = imm_u;
        csr_we = REG_WD;
      end
      OP_AUIPC: begin
        optype = UTYPE;
        alu_op = ALU_ADD;
        pc_input_type = PC_INPUT_NEXT;
        alu_input1_type = ALU_INPUT1_PC;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_ALU;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = imm_u;
        csr_we = REG_WD;
      end
      OP_JAL: begin
        optype = JTYPE;
        alu_op = ALU_JAL;
        pc_input_type = PC_INPUT_ALU;
        alu_input1_type = ALU_INPUT1_PC;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_PC;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = imm_j;
        csr_we = REG_WD;
      end
      OP_JALR: begin
        optype = ITYPE;
        alu_op = ALU_JALR;
        pc_input_type = PC_INPUT_ALU;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_PC;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = imm_i;
        csr_we = REG_WD;
      end
      OP_BRANCH: begin
        optype = BTYPE;
        pc_input_type = PC_INPUT_ALU;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_RS2;
        wb_from = WB_NONE;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        r_we = REG_WD;
        mem_op = MEM_LOAD;
        imm = imm_b;
        csr_we = REG_WD;
        case (funct3)
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
        pc_input_type = PC_INPUT_NEXT;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_MEM;
        ram_mask = RAM_MASK_W;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = imm_i;
        csr_we = REG_WD;
        case (funct3)
          3'b000: begin // LB
            alu_op = ALU_ADD;
            reg_mask = REG_MASK_BX;
          end
          3'b001: begin // LH
            alu_op = ALU_ADD;
            reg_mask = REG_MASK_HX;
          end
          3'b010: begin // LW
            alu_op = ALU_ADD;
            reg_mask = REG_MASK_W;
          end
          3'b100: begin // LBU
            alu_op = ALU_ADD;
            reg_mask = REG_MASK_B;
          end
          3'b101: begin // LHU
            alu_op = ALU_ADD;
            reg_mask = REG_MASK_H;
          end
          default: begin
            // never happens
            alu_op = ALU_NOP;
            reg_mask = REG_MASK_W;
          end
        endcase
      end
      OP_STORE: begin
        optype = STYPE;
        pc_input_type = PC_INPUT_NEXT;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_NONE;
        reg_mask = REG_MASK_W;
        r_we = REG_WD;
        mem_op = MEM_STORE;
        imm = imm_s;
        csr_we = REG_WD;
        case (funct3)
          3'b000: begin // SB
            alu_op = ALU_ADD;
            ram_mask = RAM_MASK_B;
          end
          3'b001: begin // SH
            alu_op = ALU_ADD;
            ram_mask = RAM_MASK_H;
          end
          3'b010: begin // SW
            alu_op = ALU_ADD;
            ram_mask = RAM_MASK_W;
          end
          default: begin
            // never happens
            alu_op = ALU_NOP;
            ram_mask = RAM_MASK_W;
          end
        endcase
      end
      OP_OPIMM: begin
        optype = ITYPE;
        pc_input_type = PC_INPUT_NEXT;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_IMM;
        wb_from = WB_ALU;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = imm_i;
        csr_we = REG_WD;
        unique case (funct3)
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
            if (imm_i[11:5] == 7'b0000000) begin
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
        pc_input_type = PC_INPUT_NEXT;
        alu_input1_type = ALU_INPUT1_RS1;
        alu_input2_type = ALU_INPUT2_RS2;
        wb_from = WB_ALU;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        r_we = REG_WE;
        mem_op = MEM_LOAD;
        imm = 32'b0;
        csr_we = REG_WD;
        unique case (funct3)
          3'b000: begin // ADD, SUB
            if (funct7 == 7'b0000000) begin
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
            if (funct7 == 7'b0000000) begin
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
        pc_input_type = PC_INPUT_NEXT;
        alu_input1_type = ALU_INPUT1_NONE;
        alu_input2_type = ALU_INPUT2_NONE;
        wb_from = WB_NONE;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        r_we = REG_WD;
        mem_op = MEM_LOAD;
        imm = 32'b0;
        csr_we = REG_WD;
        // if (type_i.funct3 == 3'b000) begin // FENCE
        //   csr_op = CSR_NOP;
        // end else begin // FENCE.I
        //   csr_op = CSR_NOP;
        // end
      end
      OP_SYSTEM: begin
        optype = ITYPE;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        mem_op = MEM_LOAD;
        imm = unsigned_imm_i; // {20'b0, type_i.imm};
        unique case (funct3)
          3'b000: begin
            // if (type_i.imm == 12'b000000000000) begin // ECALL
            //   csr_op = CSR_NOP;
            // end else begin // EBREAK
            //   csr_op = CSR_NOP;
            // end
            if (imm_i[11:0] == 12'b000000000000) begin // ECALL
              pc_input_type = PC_INPUT_CSR;
              imm = 32'h305;
            end else begin // EBREAK
              pc_input_type = PC_INPUT_NEXT;
              imm = 32'h0;
            end
            alu_op = ALU_NOP;
            alu_input1_type = ALU_INPUT1_NONE;
            alu_input2_type = ALU_INPUT2_NONE;
            wb_from = WB_NONE;
            r_we = REG_WD;
            csr_we = REG_WD;
          end
          3'b001: begin // CSRRW
            alu_op = ALU_ADD;
            pc_input_type = PC_INPUT_NEXT;
            alu_input1_type = ALU_INPUT1_RS1;
            alu_input2_type = ALU_INPUT2_NONE;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b010: begin // CSRRS
            alu_op = ALU_OR;
            pc_input_type = PC_INPUT_NEXT;
            alu_input1_type = ALU_INPUT1_CSR;
            alu_input2_type = ALU_INPUT2_RS1;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b011: begin // CSRRC
            alu_op = ALU_CSRRC;
            pc_input_type = PC_INPUT_NEXT;
            alu_input1_type = ALU_INPUT1_CSR;
            alu_input2_type = ALU_INPUT2_RS1;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b101: begin // CSRRWI
            alu_op = ALU_ADD;
            pc_input_type = PC_INPUT_NEXT;
            alu_input1_type = ALU_INPUT1_IMM;
            alu_input2_type = ALU_INPUT2_NONE;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b110: begin // CSRRSI
            alu_op = ALU_OR;
            pc_input_type = PC_INPUT_NEXT;
            alu_input1_type = ALU_INPUT1_CSR;
            alu_input2_type = ALU_INPUT2_IMM;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          3'b111: begin // CSRRCI
            alu_op = ALU_CSRRC;
            pc_input_type = PC_INPUT_NEXT;
            alu_input1_type = ALU_INPUT1_CSR;
            alu_input2_type = ALU_INPUT2_RS1;
            wb_from = WB_CSR;
            r_we = REG_WE;
            csr_we = REG_WE;
          end
          default: begin
            alu_op = ALU_NOP;
            pc_input_type = PC_INPUT_NEXT;
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
        pc_input_type = PC_INPUT_NEXT;
        alu_input1_type = ALU_INPUT1_NONE;
        alu_input2_type = ALU_INPUT2_NONE;
        wb_from = WB_NONE;
        reg_mask = REG_MASK_W;
        ram_mask = RAM_MASK_W;
        r_we = REG_WD;
        csr_we = REG_WD;
        mem_op = MEM_LOAD;
        imm = 32'b0;
      end
    endcase
  end
endmodule

`endif