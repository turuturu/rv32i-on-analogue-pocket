`ifndef __DEFINE_SV
`define __DEFINE_SV

typedef enum logic [5:0] {
  RV_ALU_LUI,
  RV_ALU_AUIPC,
  RV_ALU_JAL,
  RV_ALU_JALR,
  RV_ALU_BEQ,
  RV_ALU_BNE,
  RV_ALU_BLT,
  RV_ALU_BGE,
  RV_ALU_BLTU,
  RV_ALU_BGEU
} alu_op_e /*verilator public*/;

`endif
