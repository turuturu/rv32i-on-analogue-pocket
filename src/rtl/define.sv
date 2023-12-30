`ifndef __DEFINE_SV
`define __DEFINE_SV

typedef enum logic [5:0] {
  RV_LUI,
  RV_AUIPC,
  RV_JAL,
  RV_JALR,
  RV_BEQ,
  RV_BNE,
  RV_BLT,
  RV_BGE,
  RV_BLTU,
  RV_BGEU,
  RV_LB,
  RV_LH,
  RV_LW,
  RV_LBU,
  RV_LHU,
  RV_SB,
  RV_SH,
  RV_SW,
  RV_ADDI,
  RV_SLTI,
  RV_SLTIU,
  RV_XORI,
  RV_ORI,
  RV_ANDI,
  RV_SLLI,
  RV_SRLI,
  RV_SRAI,
  RV_ADD,
  RV_SUB,
  RV_SLL,
  RV_SLT,
  RV_SLTU,
  RV_XOR,
  RV_SRL,
  RV_SRA,
  RV_OR,
  RV_AND,
  RV_FENCE,
  RV_ECALL,
  RV_EBREAK,
  RV_CSRRW,
  RV_CSRRS,
  RV_CSRRC,
  RV_CSRRWI,
  RV_CSRRSI,
  RV_CSRRCI
} rv_op_e /*verilator public*/;

typedef enum logic [6:0] {
  LUI    = 7'b0110111,
  AUIPC  = 7'b0010111,
  JAL    = 7'b1101111,
  JALR   = 7'b1100111,
  BRANCH = 7'b1100011,
  LOAD   = 7'b0000011,
  STORE  = 7'b0100011,
  OPIMM  = 7'b0010011,
  OP     = 7'b0110011,
  FENCE  = 7'b0001111,
  SYSTEM = 7'b1110011
} opcode_e /*verilator public*/;

typedef enum logic [2:0] {
  RTYPE,
  ITYPE,
  STYPE,
  BTYPE,
  UTYPE,
  JTYPE
} optype_e /*verilator public*/;


`endif
