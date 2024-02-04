`ifndef __RV32I_REG_MASK_SV
`define __RV32I_REG_MASK_SV

`include "rv32i/rv32i.sv" 

module reg_mask import rv32i::*;
(
    input logic [31:0] data,
    input reg_mask_e reg_mask_type,
    output logic [31:0] masked_data
);
  always_comb begin
    case (reg_mask_type)
      REG_MASK_B: masked_data = {24'b0, data[7:0]};
      REG_MASK_H: masked_data = {16'b0, data[15:0]};
      REG_MASK_BX: masked_data = {{24{data[7]}}, data[7:0]};
      REG_MASK_HX: masked_data = {{16{data[15]}}, data[15:0]};
      REG_MASK_W: masked_data = data;
      default: masked_data = data;
    endcase
  end
endmodule

`endif