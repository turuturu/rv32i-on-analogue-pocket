`ifndef __RV32I_CACHE_SV
`define __RV32I_CACHE_SV

`include "rv32i/rv32i.sv" 

module rom_cache import rv32i::*;
(
    input logic clk,
    input rv32i_rom_cache_key_s addr,
    input logic [31:0] wdata[2**`CACHE_WORD_ADR_SIZE-1:0],
    input cache_op_e cache_op,
    output logic hit,
    output logic [31:0] rdata
);
  rv32i_rom_cache_data_s inner_data;
  logic [31:0] multi_word_data[2**`CACHE_WORD_ADR_SIZE - 1:0];
  rv32i_rom_cache_data_s inner_mem [(2**`CACHE_LENGTH)-1:0]/*verilator public*/;
  always_ff @(posedge clk) begin
    if (cache_op == CACHE_STORE) begin
      inner_mem[addr.index] <= '{
        isvalid: 1,
        tag: addr.tag,
        // data: wdata
        data: {wdata[3],wdata[2],wdata[1],wdata[0]}
      };
    end
  end
  assign inner_data = inner_mem[addr.index];
  assign multi_word_data[0] = inner_data.data[31:0];
  assign multi_word_data[1] = inner_data.data[63:32];
  assign multi_word_data[2] = inner_data.data[95:64];
  assign multi_word_data[3] = inner_data.data[127:96];

  assign rdata = cache_op == CACHE_STORE ? wdata[addr.word_addr] : multi_word_data[addr.word_addr];
  assign hit = cache_op == CACHE_STORE | inner_data.isvalid & (inner_data.tag == addr.tag);
  // assign rdata = multi_word_data[addr.word_addr];
  // assign hit = inner_data.isvalid & (inner_data.tag == addr.tag);
  // assign rdata = inner_data.data;
  // assign hit = inner_data.isvalid & (inner_data.tag == addr.tag);
endmodule
`endif
