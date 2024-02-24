`ifndef __RV32I_RAM_MASK_SV
`define __RV32I_RAM_MASK_SV

`include "rv32i/rv32i.sv" 

module ram_mask import rv32i::*;
(
    input logic [31:0] data,
    input ram_mask_e ram_mask_type,
    output logic [31:0] masked_data
);
  always_comb begin
    case (ram_mask_type)
      RAM_MASK_B: masked_data = {24'b0, data[7:0]};
      RAM_MASK_H: masked_data = {16'b0, data[15:0]};
      RAM_MASK_W: masked_data = data;
      default: masked_data = data;
    endcase
  end
endmodule

`endif