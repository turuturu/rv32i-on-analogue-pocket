`ifndef __RV32I_RV32I_TOP_WRAPPER_SV
`define __RV32I_RV32I_TOP_WRAPPER_SV

`include "rv32i/rv32i_top.sv"
`include "rv32i/rv32i.sv"
`include "rv32i/rom.sv"

module rv32i_top_wrapper import rv32i::*;
(
    input logic clk,
    input logic reset_n
);

  logic [31:0] ram_addr2;
  logic [31:0] ram_out2;
  logic [31:0] rom_addr/*verilator public*/;
  logic [31:0] rom_out/*verilator public*/;
  logic stall/*verilator public*/;
  logic rom_oe/*verilator public*/;
  logic rom_re/*verilator public*/;

  rv32i_top rv32i_top0(
    // -- Inputs
    .clk(clk),
    .reset_n(reset_n),
    .rom_out(rom_out),
    .rom_oe(rom_oe),
    .ram_addr2(ram_addr2),
    // -- Outputs
    .rom_addr(rom_addr),
    .rom_re(rom_re),
    .ram_out2(ram_out2)
  );

  rom rom0(
    // -- Inputs
    .clk(clk),
    .addr(rom_addr),
    .re(rom_re),
    // -- Outputs
    .data(rom_out),
    .oe(rom_oe)
  );



endmodule

`endif
