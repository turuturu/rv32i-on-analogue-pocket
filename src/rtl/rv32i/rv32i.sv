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
  ALU_CSRRC,
  ALU_NOP
} alu_op_e /*verilator public*/;

typedef enum logic [1:0] {
  PC_INPUT_NEXT,
  PC_INPUT_ALU,
  PC_INPUT_CSR
} pc_input_type_e /*verilator public*/;

typedef enum logic [2:0] {
  ALU_INPUT1_IMM,
  ALU_INPUT1_RS1,
  ALU_INPUT1_PC,
  ALU_INPUT1_CSR,
  ALU_INPUT1_NONE
} alu_input1_type_e /*verilator public*/;

typedef enum logic [1:0] {
  ALU_INPUT2_IMM,
  ALU_INPUT2_RS1,
  ALU_INPUT2_RS2,
  ALU_INPUT2_NONE
} alu_input2_type_e /*verilator public*/;

typedef enum logic [1:0] {
  CSR_ALU_INPUT_IMM,
  CSR_ALU_INPUT_RS1,
  CSR_ALU_INPUT_NONE
} csr_alu_input_type_e /*verilator public*/;

typedef enum logic {
  MEM_LOAD,
  MEM_STORE
} mem_op_e /*verilator public*/;

typedef enum logic [1:0] {
  BRANCH_ABSOLUTE,
  BRANCH_RELATIVE,
  BRANCH_NONE
} branch_type_e /*verilator public*/;

typedef enum logic {
  REG_WE,
  REG_WD
} reg_we_e /*verilator public*/;

typedef enum logic [2:0] {
  WB_MEM,
  WB_ALU,
  WB_PC,
  WB_CSR,
  WB_NONE
} wb_from_e /*verilator public*/;

typedef enum logic [2:0] {
  REG_MASK_B,
  REG_MASK_H,
  REG_MASK_BX,
  REG_MASK_HX,
  REG_MASK_W
} reg_mask_e /*verilator public*/;

typedef enum logic [1:0] {
  RAM_MASK_B,
  RAM_MASK_H,
  RAM_MASK_W
} ram_mask_e /*verilator public*/;

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

typedef enum logic [1:0] {
  PV_USER       = 2'b00,
  PV_SUPERVISOR = 2'b01,
  PV_HYPERVISOR = 2'b10,
  PV_MACHINE    = 2'b11
} privilege_level_e/*verilator public*/;

typedef enum logic [1:0] {
  CSR_NOP,
  CSR_RW,
  CSR_RS,
  CSR_RC
} csr_op_e/*verilator public*/;

typedef struct packed {
  logic [6:0] funct7;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] rd;
  logic [6:0] opcode;
} rv32i_r_type_s;

typedef struct packed {
  logic [11:0] imm;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] rd;
  logic [6:0] opcode;
} rv32i_i_type_s;

typedef struct packed {
  logic [6:0] imm1;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] imm2;
  logic [6:0] opcode;
} rv32i_s_type_s;

typedef struct packed {
  logic [6:0] imm1;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] imm2;
  logic [6:0] opcode;
} rv32i_b_type_s;

typedef struct packed {
  logic [19:0] imm;
  logic [4:0] rd;
  logic [6:0] opcode;
} rv32i_u_type_s;

typedef struct packed {
  logic [19:0] imm;
  logic [4:0] rd;
  logic [6:0] opcode;
} rv32i_j_type_s;

endpackage
`endif
