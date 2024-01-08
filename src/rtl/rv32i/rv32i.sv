`ifndef __RV32I_DEFINE_SV
`define __RV32I_DEFINE_SV

package rv32i;
typedef enum logic [4:0] {
  ALU_JAL,
  ALU_JALR,
  ALU_BEQ,
  ALU_BNE,
  ALU_BLT,
  ALU_BGE,
  ALU_BLTU,
  ALU_BGEU,
  ALU_ADD,
  ALU_SUB,
  ALU_SLL,
  ALU_SLT,
  ALU_SLTU,
  ALU_XOR,
  ALU_SRL,
  ALU_SRA,
  ALU_OR,
  ALU_AND,
  ALU_NOP
} alu_op_e /*verilator public*/;

typedef enum logic [6:0] {
  OP_LUI    = 7'b0110111,
  OP_AUIPC  = 7'b0010111,
  OP_JAL    = 7'b1101111,
  OP_JALR   = 7'b1100111,
  OP_BRANCH = 7'b1100011,
  OP_LOAD   = 7'b0000011,
  OP_STORE  = 7'b0100011,
  OP_OPIMM  = 7'b0010011,
  OP_OP     = 7'b0110011,
  OP_FENCE  = 7'b0001111,
  OP_SYSTEM = 7'b1110011
} opcode_e /*verilator public*/;

typedef enum logic [2:0] {
  RTYPE,
  ITYPE,
  STYPE,
  BTYPE,
  UTYPE,
  JTYPE
} optype_e /*verilator public*/;

typedef struct packed {
  logic [6:0] funct7;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] rd;
  opcode_e opcode;
} rv32i_r_type_s;

typedef struct packed {
  logic [11:0] imm;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] rd;
  opcode_e opcode;
} rv32i_i_type_s;

typedef struct packed {
  logic [6:0] imm1;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] imm2;
  opcode_e opcode;
} rv32i_s_type_s;

typedef struct packed {
  logic [6:0] imm1;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] imm2;
  opcode_e opcode;
} rv32i_b_type_s;

typedef struct packed {
  logic [19:0] imm;
  logic [4:0] rd;
  opcode_e opcode;
} rv32i_u_type_s;

typedef struct packed {
  logic [19:0] imm;
  logic [4:0] rd;
  opcode_e opcode;
} rv32i_j_type_s;

typedef union packed {
  rv32i_r_type_s type_r;
  rv32i_i_type_s type_i;
  rv32i_s_type_s type_s;
  rv32i_b_type_s type_b;
  rv32i_u_type_s type_u;
  rv32i_j_type_s type_j;
} rv32i_inst_u;

endpackage
`endif
