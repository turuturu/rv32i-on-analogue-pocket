typedef enum logic [5:0] {
  ALU_LUI,
  ALU_AUIPC,
  ALU_JAL,
  ALU_JALR,
  ALU_BEQ,
  ALU_BNE,
  ALU_BLT,
  ALU_BGE,
  ALU_BLTU,
  ALU_BGEU
} alu_op_e /*verilator public*/;