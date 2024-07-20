`ifndef __RV32I_RAM_SV
`define __RV32I_RAM_SV

`include "rv32i/rv32i.sv" 

module ram import rv32i::*;
#(
  parameter ADDR_LENGTH = 21, // 1MB
  // parameter ADDR_LENGTH = 14, // 16KB
  // parameter ADDR_LENGTH = 10, // 1KB
  parameter MEM_SIZE = (2**ADDR_LENGTH) / 4
) (
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input mem_op_e mem_op,
    input ram_mask_e ram_mask,
    output logic [31:0] rdata
);

  (* ramstyle = "M10K" *)logic [7:0] inner_ram0 [0:MEM_SIZE-1]/*verilator public*/;
  (* ramstyle = "M10K" *)logic [7:0] inner_ram1 [0:MEM_SIZE-1]/*verilator public*/;
  (* ramstyle = "M10K" *)logic [7:0] inner_ram2 [0:MEM_SIZE-1]/*verilator public*/;
  (* ramstyle = "M10K" *)logic [7:0] inner_ram3 [0:MEM_SIZE-1]/*verilator public*/;
  logic [ADDR_LENGTH-1-2:0] addr0;
  logic [ADDR_LENGTH-1-2:0] addr1;
  logic [ADDR_LENGTH-1-2:0] addr2;
  logic [ADDR_LENGTH-1-2:0] addr3;
  assign addr0 = addr[ADDR_LENGTH-1-2:0];
  assign addr1 = addr0 + 1;
  assign addr2 = addr0 + 2;
  assign addr3 = addr0 + 3;
  logic [7:0] wdata0;
  logic [7:0] wdata1;
  logic [7:0] wdata2;
  logic [7:0] wdata3;
  assign wdata0 = wdata[7:0];
  assign wdata1 = wdata[15:8];
  assign wdata2 = wdata[23:16];
  assign wdata3 = wdata[31:24];
  logic [7:0] odata0;
  logic [7:0] odata1;
  logic [7:0] odata2;
  logic [7:0] odata3;
  assign odata0 = inner_ram0[addr0];
  assign odata1 = inner_ram1[addr1];
  assign odata2 = inner_ram2[addr2];
  assign odata3 = inner_ram3[addr3];
  
     
  // logic [7:0] inner_ram [0:255]/*verilator public*/; // 1KB
  // logic [ADDR_LENGTH-1:0] inner_addr/*verilator public*/;
  always_ff @(posedge clk) begin
    if (mem_op == MEM_STORE) begin
      case (ram_mask)
      RAM_MASK_B: begin
        inner_ram0[addr0] <= wdata0;
      end
      RAM_MASK_H: begin
        inner_ram0[addr0] <= wdata0;
        inner_ram1[addr1] <= wdata1;
      end
      RAM_MASK_W: begin
        inner_ram0[addr0] <= wdata0;
        inner_ram1[addr1] <= wdata1;
        inner_ram2[addr2] <= wdata2;
        inner_ram3[addr3] <= wdata3;
      end
      default: begin
        inner_ram0[addr0] <= wdata0;
        inner_ram1[addr1] <= wdata1;
        inner_ram2[addr2] <= wdata2;
        inner_ram3[addr3] <= wdata3;
      end
      endcase
    end
  end
  // assign inner_addr = addr[ADDR_LENGTH-1:0];
  assign rdata = ram_mask == RAM_MASK_B ? {24'b0, odata0} : 
                 ram_mask == RAM_MASK_H ? {16'b0, odata1,odata0} : 
                 {odata3, odata2, odata1, odata0}; //ram_mask == RAM_MASK_W
endmodule

`endif