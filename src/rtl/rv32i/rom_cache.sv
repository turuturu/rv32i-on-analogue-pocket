`ifndef __RV32I_CACHE_SV
`define __RV32I_CACHE_SV

`include "rv32i/rv32i.sv" 

module rom_cache import rv32i::*;
(
    input logic clk,
    input rv32i_rom_cache_key_s addr,
    input logic [31:0] wdata,
    input cache_op_e cache_op,
    output logic hit,
    output logic [31:0] rdata
);
  rv32i_rom_cache_data_s inner_data;
  rv32i_rom_cache_data_s inner_mem [0:(2**`CACHE_LENGTH)-1]/*verilator public*/;
  always_ff @(posedge clk) begin
    if (cache_op == CACHE_STORE) begin
      inner_mem[addr.index] <= '{
        isvalid: 1,
        tag: addr.tag,
        data: wdata
      };
    end
  end
  assign inner_data = inner_mem[addr.index];
  assign rdata = cache_op == CACHE_STORE ? wdata : inner_data.data;
  assign hit = cache_op == CACHE_STORE | inner_data.isvalid & (inner_data.tag == addr.tag);
  // assign rdata = inner_data.data;
  // assign hit = inner_data.isvalid & (inner_data.tag == addr.tag);
endmodule
`endif
