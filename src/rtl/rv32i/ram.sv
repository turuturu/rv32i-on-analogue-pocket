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
    input logic [31:0] addr1,
    input logic [31:0] addr2,
    input logic [31:0] wdata,
    input mem_op_e mem_op,
    input ram_mask_e ram_mask,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2
);

  (* ramstyle = "M10K" *)logic [7:0] inner_ram0 [0:MEM_SIZE-1]/*verilator public*/;
  (* ramstyle = "M10K" *)logic [7:0] inner_ram1 [0:MEM_SIZE-1]/*verilator public*/;
  (* ramstyle = "M10K" *)logic [7:0] inner_ram2 [0:MEM_SIZE-1]/*verilator public*/;
  (* ramstyle = "M10K" *)logic [7:0] inner_ram3 [0:MEM_SIZE-1]/*verilator public*/;
  logic [ADDR_LENGTH-1-2:0] addr1_0;
  logic [ADDR_LENGTH-1-2:0] addr1_1;
  logic [ADDR_LENGTH-1-2:0] addr1_2;
  logic [ADDR_LENGTH-1-2:0] addr1_3;
  logic [ADDR_LENGTH-1-2:0] addr2_0;
  logic [ADDR_LENGTH-1-2:0] addr2_1;
  logic [ADDR_LENGTH-1-2:0] addr2_2;
  logic [ADDR_LENGTH-1-2:0] addr2_3;
  logic [ADDR_LENGTH-1-2:0] waddr0;
  logic [ADDR_LENGTH-1-2:0] waddr1;
  logic [ADDR_LENGTH-1-2:0] waddr2;
  logic [ADDR_LENGTH-1-2:0] waddr3;
  logic [1:0] offset1;
  logic [1:0] offset2;
  assign offset1 = addr1[1:0];
  assign offset2 = addr2[1:0];
  assign addr1_0 = addr1[ADDR_LENGTH-1:2] + (offset1 < 1 ? 0 : 1);
  assign addr1_1 = addr1[ADDR_LENGTH-1:2] + (offset1 < 2 ? 0 : 1);
  assign addr1_2 = addr1[ADDR_LENGTH-1:2] + (offset1 < 3 ? 0 : 1);
  assign addr1_3 = addr1[ADDR_LENGTH-1:2];
  assign addr2_0 = addr2[ADDR_LENGTH-1:2] + (offset2 < 1 ? 0 : 1);
  assign addr2_1 = addr2[ADDR_LENGTH-1:2] + (offset2 < 2 ? 0 : 1);
  assign addr2_2 = addr2[ADDR_LENGTH-1:2] + (offset2 < 3 ? 0 : 1);
  assign addr2_3 = addr2[ADDR_LENGTH-1:2];

  assign waddr0 = addr1[ADDR_LENGTH-1:2];
  assign waddr1 = addr1[ADDR_LENGTH-1:2] + (offset1 < 3 ? 0 : 1);
  assign waddr2 = addr1[ADDR_LENGTH-1:2] + (offset1 < 2 ? 0 : 1);
  assign waddr3 = addr1[ADDR_LENGTH-1:2] + (offset1 < 1 ? 0 : 1);
  logic [7:0] wdata0;
  logic [7:0] wdata1;
  logic [7:0] wdata2;
  logic [7:0] wdata3;
  assign wdata0 = wdata[7:0];
  assign wdata1 = wdata[15:8];
  assign wdata2 = wdata[23:16];
  assign wdata3 = wdata[31:24];
  logic [7:0] odata1_0;
  logic [7:0] odata1_1;
  logic [7:0] odata1_2;
  logic [7:0] odata1_3;
  logic [7:0] odata2_0;
  logic [7:0] odata2_1;
  logic [7:0] odata2_2;
  logic [7:0] odata2_3;
  assign odata1_0 = inner_ram0[addr1_0];
  assign odata1_1 = inner_ram1[addr1_1];
  assign odata1_2 = inner_ram2[addr1_2];
  assign odata1_3 = inner_ram3[addr1_3];
  assign odata2_0 = inner_ram0[addr2_0];
  assign odata2_1 = inner_ram1[addr2_1];
  assign odata2_2 = inner_ram2[addr2_2];
  assign odata2_3 = inner_ram3[addr2_3];
  always_ff @(posedge clk) begin
    if (mem_op == MEM_STORE) begin
      case (ram_mask)
      RAM_MASK_B: begin
        case(offset1)
          0: inner_ram0[waddr0] <= wdata0;
          1: inner_ram1[waddr0] <= wdata0;
          2: inner_ram2[waddr0] <= wdata0;
          3: inner_ram3[waddr0] <= wdata0;
       endcase
      end
      RAM_MASK_H: begin
        case(offset1)
          0: begin
            inner_ram0[waddr0] <= wdata0;
            inner_ram1[waddr1] <= wdata1;
          end
          1: begin
            inner_ram1[waddr0] <= wdata0;
            inner_ram2[waddr1] <= wdata1;
          end
          2: begin
            inner_ram2[waddr0] <= wdata0;
            inner_ram3[waddr1] <= wdata1;
          end
          3: begin
            inner_ram3[waddr0] <= wdata0;
            inner_ram0[waddr1] <= wdata1;
          end
       endcase
      end
      RAM_MASK_W: begin
        case(offset1)
          0: begin
            inner_ram0[waddr0] <= wdata0;
            inner_ram1[waddr1] <= wdata1;
            inner_ram2[waddr2] <= wdata2;
            inner_ram3[waddr3] <= wdata3;
          end
          1: begin
            inner_ram1[waddr0] <= wdata0;
            inner_ram2[waddr1] <= wdata1;
            inner_ram3[waddr2] <= wdata2;
            inner_ram0[waddr3] <= wdata3;
          end
          2: begin
            inner_ram2[waddr0] <= wdata0;
            inner_ram3[waddr1] <= wdata1;
            inner_ram0[waddr2] <= wdata2;
            inner_ram1[waddr3] <= wdata3;
          end
          3: begin
            inner_ram3[waddr0] <= wdata0;
            inner_ram0[waddr1] <= wdata1;
            inner_ram1[waddr2] <= wdata2;
            inner_ram2[waddr3] <= wdata3;
          end
       endcase
      end
      default: begin
        case(offset1)
          0: begin
            inner_ram0[waddr0] <= wdata0;
            inner_ram1[waddr1] <= wdata1;
            inner_ram2[waddr2] <= wdata2;
            inner_ram3[waddr3] <= wdata3;
          end
          1: begin
            inner_ram1[waddr0] <= wdata0;
            inner_ram2[waddr1] <= wdata1;
            inner_ram3[waddr2] <= wdata2;
            inner_ram0[waddr3] <= wdata3;
          end
          2: begin
            inner_ram2[waddr0] <= wdata0;
            inner_ram3[waddr1] <= wdata1;
            inner_ram0[waddr2] <= wdata2;
            inner_ram1[waddr3] <= wdata3;
          end
          3: begin
            inner_ram3[waddr0] <= wdata0;
            inner_ram0[waddr1] <= wdata1;
            inner_ram1[waddr2] <= wdata2;
            inner_ram2[waddr3] <= wdata3;
          end
       endcase
      end
      endcase
    end
  end
  logic [31:0] sorted_data1;
  logic [31:0] sorted_data2;
  assign sorted_data1 = offset1 == 0 ? {odata1_3, odata1_2, odata1_1, odata1_0} : 
                        offset1 == 1 ? {odata1_0, odata1_3, odata1_2, odata1_1} : 
                        offset1 == 2 ? {odata1_1, odata1_0, odata1_3, odata1_2} : 
                        {odata1_2, odata1_1, odata1_0, odata1_3};
  assign sorted_data2 = offset2 == 0 ? {odata2_3, odata2_2, odata2_1, odata2_0} : 
                        offset2 == 1 ? {odata2_0, odata2_3, odata2_2, odata2_1} : 
                        offset2 == 2 ? {odata2_1, odata2_0, odata2_3, odata2_2} : 
                        {odata2_2, odata2_1, odata2_0, odata2_3};
  assign rdata1 = ram_mask == RAM_MASK_B ? {24'b0, sorted_data1[7:0]} : 
                 ram_mask == RAM_MASK_H ? {16'b0, sorted_data1[15:0]} : 
                 sorted_data1; //ram_mask == RAM_MASK_W
  assign rdata2 = sorted_data2;
endmodule

`endif