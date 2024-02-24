`ifndef __RV32I_RAM_SV
`define __RV32I_RAM_SV

`include "rv32i/rv32i.sv" 

module ram import rv32i::*;
(
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input mem_op_e mem_op,
    input ram_mask_e ram_mask,
    output logic [31:0] rdata
);

  logic [7:0] inner_ram [0:16383]/*verilator public*/; // 4KB
  logic [13:0] inner_addr/*verilator public*/;
  always_ff @(posedge clk) begin
    if (mem_op == MEM_STORE) begin
      case (ram_mask)
      RAM_MASK_B: begin
        inner_ram[addr[13:0]] <= wdata[7:0];
      end
      RAM_MASK_H: begin
        inner_ram[addr[13:0]] <= wdata[7:0];
        inner_ram[addr[13:0]+1] <= wdata[15:8];
      end
      RAM_MASK_W: begin
        inner_ram[addr[13:0]] <= wdata[7:0];
        inner_ram[addr[13:0]+1] <= wdata[15:8];
        inner_ram[addr[13:0]+2] <= wdata[23:16];
        inner_ram[addr[13:0]+3] <= wdata[31:24];
      end
      default: begin
        inner_ram[addr[13:0]] <= wdata[7:0];
        inner_ram[addr[13:0]+1] <= wdata[15:8];
        inner_ram[addr[13:0]+2] <= wdata[23:16];
        inner_ram[addr[13:0]+3] <= wdata[31:24];
      end
      endcase
    end
  end
  assign inner_addr = addr[13:0];
  assign rdata = {inner_ram[inner_addr+3],inner_ram[inner_addr+2],inner_ram[inner_addr+1],inner_ram[inner_addr]};
endmodule

`endif