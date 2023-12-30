`include "define.sv" 


module decoder 
(
  input  logic [31:0]instr, // instruction
  output logic [4:0] rs1,   // source register 1
  output logic [4:0] rs2,   // source register 2
  output logic [4:0] rd,    // destination register
  output logic [31:0] imm,  // immediate
  output alu_op_e alu_op    // ALU operation
);
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;

  assign opcode = instr[6:0];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];

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



  always_comb begin
    unique case (opcode)
      LUI: begin
        rs1 = 0;
        rs2 = 0;
        rd = instr[11:7];
        imm = 32'(unsigned'(instr[31:12]));
        alu_op = RV_ALU_LUI;
      end
      AUIPC: begin
        rs1 = 0;
        rs2 = 0;
        rd = instr[11:7];
        imm = 32'(unsigned'(instr[31:12]));
        alu_op = RV_ALU_AUIPC;
      end
      default: begin
        rs1 = 0;
        rs2 = 0;
        rd = instr[11:7];
        imm = 32'(unsigned'(instr[31:12]));
        alu_op = RV_ALU_BGEU;
      end
    
    endcase
  end

endmodule
