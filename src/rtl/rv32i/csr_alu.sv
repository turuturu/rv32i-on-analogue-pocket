`ifndef __RV32I_CSR_ALU_SV
`define __RV32I_CSR_ALU_SV

`include "rv32i/rv32i.sv" 

module csr_alu import rv32i::*;
(
    input logic [31:0] csr_data,
    input logic [31:0] data,
    input csr_op_e csr_op,
    output logic [31:0] result
);
  always_comb begin
    case (csr_op)
      CSR_RW: begin
        result = data;
      end
      CSR_RS: begin
        result = csr_data | data;
      end
      CSR_RC: begin
        result = csr_data & ~data;
      end
      default: begin
        result = 32'b0;
      end
    endcase
  end
endmodule
`endif
