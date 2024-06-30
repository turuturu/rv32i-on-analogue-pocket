`ifndef __RV32I_RAM_SV
`define __RV32I_RAM_SV

`include "rv32i/rv32i.sv" 

module ram import rv32i::*;
#(
  // parameter ADDR_LENGTH = 14, // 16KB
  parameter ADDR_LENGTH = 10, // 1KB
  parameter MEM_SIZE = 2**ADDR_LENGTH
) (
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input mem_op_e mem_op,
    input ram_mask_e ram_mask,
    output logic [31:0] rdata
);

  logic [7:0] inner_ram [0:MEM_SIZE-1]/*verilator public*/;
  // logic [7:0] inner_ram [0:255]/*verilator public*/; // 1KB
  logic [ADDR_LENGTH-1:0] inner_addr/*verilator public*/;
  always_ff @(posedge clk) begin
    if (mem_op == MEM_STORE) begin
      case (ram_mask)
      RAM_MASK_B: begin
        inner_ram[addr[ADDR_LENGTH-1:0]] <= wdata[7:0];
      end
      RAM_MASK_H: begin
        inner_ram[addr[ADDR_LENGTH-1:0]] <= wdata[7:0];
        inner_ram[addr[ADDR_LENGTH-1:0]+1] <= wdata[15:8];
      end
      RAM_MASK_W: begin
        inner_ram[addr[ADDR_LENGTH-1:0]] <= wdata[7:0];
        inner_ram[addr[ADDR_LENGTH-1:0]+1] <= wdata[15:8];
        inner_ram[addr[ADDR_LENGTH-1:0]+2] <= wdata[23:16];
        inner_ram[addr[ADDR_LENGTH-1:0]+3] <= wdata[31:24];
      end
      default: begin
        inner_ram[addr[ADDR_LENGTH-1:0]] <= wdata[7:0];
        inner_ram[addr[ADDR_LENGTH-1:0]+1] <= wdata[15:8];
        inner_ram[addr[ADDR_LENGTH-1:0]+2] <= wdata[23:16];
        inner_ram[addr[ADDR_LENGTH-1:0]+3] <= wdata[31:24];
      end
      endcase
    end
  end
  assign inner_addr = addr[ADDR_LENGTH-1:0];
  assign rdata = ram_mask == RAM_MASK_B ? {24'b0, inner_ram[inner_addr]} : 
                 ram_mask == RAM_MASK_H ? {16'b0, inner_ram[inner_addr+1],inner_ram[inner_addr]} : 
                 {inner_ram[inner_addr+3],inner_ram[inner_addr+2],inner_ram[inner_addr+1],inner_ram[inner_addr]}; //ram_mask == RAM_MASK_W
endmodule

`endif