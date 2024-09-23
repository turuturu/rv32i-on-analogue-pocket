`ifndef __RV32I_RV32I_TOP_SV
`define __RV32I_RV32I_TOP_SV

`include "rv32i/rv32i.sv"
`include "rv32i/alu.sv"
`include "rv32i/csr_registers.sv"
`include "rv32i/decoder.sv"
`include "rv32i/ram.sv"
`include "rv32i/reg_mask.sv"
`include "rv32i/registers.sv"
// `include "rv32i/rom.sv"
// `include "rv32i/psram.sv"

module rv32i_top import rv32i::*;
(
    input logic clk,
    input logic stall,
    input logic reset_n,
    input logic [31:0] instr,
    input logic rom_oe,
    input wire [31:0] ram_addr2,
    output logic [31:0] rom_addr,
    output logic rom_re,
    output wire [31:0] ram_out2
);
  logic [31:0] pc;
  logic [31:0] next_pc;
  logic miss;

  branch_type_e branch_type;               // branch type
  csr_op_e csr_op;                         // CSR operation
  logic [11:0] csr_addr;                   // CSR address
  csr_alu_input_type_e csr_alu_input_type; // CSR ALU input type

  logic [31:0] masked_reg_wb; // masked reg write back
  logic [31:0] masked_alu_result_ram; // masked alu result
  logic [31:0] csr_alu_result; // csr alu result
  logic [31:0] csr_alu_input; // csr alu input
  logic [31:0] ram_out; // ram output
  // logic [31:0] ram_out2; // ram output
  logic [31:0] reg_wb; // register write back
  logic [31:0] masked_alu_result; // register write back
  logic loaduse;
  logic p3_forwarding;
  logic p4_forwarding;

  assign rom_re = 1;
  // logic rom_oe;
  // // IF Stage
  // rom rom0(
  //   // -- Inputs
  //   .clk,
  //   .addr(next_pc),
  //   .re(rom_re),
  //   // -- Outputs
  //   .data(instr),
  //   .oe(rom_oe)
  // );


  assign loaduse = p3_valid & 
    (
      p3_wb_from == WB_MEM &
      (
        p2_alu_input1_type == ALU_INPUT1_RS1 & p3_rd == p2_rs1 |
        p2_alu_input2_type == ALU_INPUT2_RS1 & p3_rd == p2_rs1 |
        p2_alu_input2_type == ALU_INPUT2_RS2 & p3_rd == p2_rs2
      )
    );

  assign p3_forwarding = p3_valid && 
    p3_mem_op != MEM_STORE &&
    p3_branch_type == BRANCH_NONE;
  assign p4_forwarding = p4_valid && 
    p4_mem_op != MEM_STORE &&
    p4_branch_type == BRANCH_NONE;

  assign next_pc = stall ? pc:
                   loaduse ? pc:
                   reset_n == 0 ? 0:
                   !miss ? pc + 4:
                   p2_pc_input_type == PC_INPUT_CSR ? p2_csr_data :
                   p2_pc_input_type == PC_INPUT_NEXT ? p2_pc + 4 :
                   p2_pc_input_type == PC_INPUT_ALU ? (
                     branch_type == BRANCH_RELATIVE ? p2_pc + p2_imm :
                     branch_type == BRANCH_ABSOLUTE ? alu_result :
                     p2_pc + 4 // BRANCH_NONE
                   ) : p2_pc;
  assign rom_addr = next_pc;

  always_ff @(posedge clk or negedge reset_n) begin
    if (reset_n == 0) begin
      pc <= 32'h8000_0000;
    end else begin
      pc <= next_pc;
    end
  end
  
  // pipe line 1
  // logic [31:0] instr; // instruction

  logic [31:0] p1_pc = 0; // pipe line 1 pc
  logic [31:0] p1_instr; // pipe line 1 instruction
  logic p1_valid = 0; // pipe line 1 valid

  always_ff @(posedge clk) begin
    if(!loaduse) begin
      p1_pc <= pc;
      p1_instr <= reset_n ? instr : 32'h0000_0000;
      p1_valid <= !miss;
    end
  end

  assign miss = (
    (
      (p2_pc_input_type == PC_INPUT_ALU && branch_type != BRANCH_NONE) || 
      p2_pc_input_type == PC_INPUT_CSR
    ) && 
    p2_valid
  );

  // pipe line 2
  logic [31:0] rs1_data; // rs1 output
  logic [31:0] rs2_data; // rs2 output
  logic [31:0] csr_data; // csr alu result
  logic [31:0] alu_input1; // alu input 1
  logic [31:0] alu_input2; // alu input 2
  logic [31:0] alu_result; // alu result
  logic [4:0] rs1; // source register 1
  logic [4:0] rs2; // source register 2
  logic [4:0] rd; // destination register
  logic [31:0] imm; // immediate
  reg_we_e csr_we; // CSR write enable
  pc_input_type_e pc_input_type; // PC INPUT
  alu_input1_type_e alu_input1_type; // ALU INPUT TYPE 1
  alu_input2_type_e alu_input2_type; // ALU INPUT TYPE 2
  alu_op_e alu_op; // ALU operation
  wb_from_e wb_from; // write back from
  reg_we_e r_we; // register write enable
  reg_mask_e reg_mask; // reg mask
  ram_mask_e ram_mask; // ram mask
  mem_op_e mem_op; // memory write enable
  logic [31:0] forwarding_alu_input1;
  logic [31:0] forwarding_alu_input2;
  logic [31:0] forwarding_rs2_data;

  logic [31:0] p2_pc = 0; // pipe line 2 pc
  logic [31:0] p2_alu_input1; // pipe line 2 alu_input1
  logic [31:0] p2_alu_input2; // pipe line 2 alu_input2
  logic [4:0] p2_rs1; // source register 1
  logic [4:0] p2_rs2; // source register 2
  logic [4:0] p2_rd; // pipe line 2 destination register
  logic [31:0] p2_rs2_data; // pipe line 2 rs2_data
  logic [31:0] p2_imm; // pipe line 2 immediate
  logic [31:0] p2_csr_data; // pipe line 2 csr alu result
  logic [11:0] p2_csr_addr; // pipe line 2 CSR address
  pc_input_type_e p2_pc_input_type = PC_INPUT_NEXT; // pipe line 2 PC INPUT
  alu_input1_type_e p2_alu_input1_type; // ALU INPUT TYPE 1
  alu_input2_type_e p2_alu_input2_type; // ALU INPUT TYPE 2
  alu_op_e p2_alu_op; // pipe line 2 alu_op
  logic p2_valid = 0; // pipe line 2 valid
  mem_op_e p2_mem_op; // pipe line 2 memory write enable
  wb_from_e p2_wb_from; // pipe line 2 write back from
  ram_mask_e p2_ram_mask; // pipe line 2 reg mask
  reg_mask_e p2_reg_mask; // pipe line 2 reg mask
  reg_we_e p2_r_we; // pipe line 2 register write enable
  reg_we_e p2_csr_we; // pipe line 2 CSR write enable


  assign csr_addr = imm[11:0];
  
  always_ff @(posedge clk) begin
    if(!loaduse) begin
      p2_pc <= p1_pc;
      p2_alu_input1 <= alu_input1;
      p2_alu_input2 <= alu_input2;
      p2_rs1 <= rs1;
      p2_rs2 <= rs2;
      p2_rd <= rd;
      p2_rs2_data <= rs2_data;
      p2_imm <= imm;
      p2_csr_data <= csr_data;
      p2_pc_input_type <= pc_input_type;
      p2_alu_op <= alu_op;
      p2_valid <= !miss & p1_valid;
      p2_mem_op <= mem_op;
      p2_wb_from <= wb_from;
      p2_ram_mask <= ram_mask;
      p2_reg_mask <= reg_mask;
      p2_r_we <= r_we;
      p2_csr_we <= csr_we;
      p2_csr_addr <= csr_addr;
      p2_alu_input1_type <= alu_input1_type;
      p2_alu_input2_type <= alu_input2_type;
    end else begin
      p2_alu_input1 <= forwarding_alu_input1;
      p2_alu_input2 <= forwarding_alu_input2;
    end
  end


  // pipe line 3
  logic [31:0] p3_pc = 0; // pipe line 3 pc
  logic [31:0] p3_alu_result; // pipe line 3 alu result
  logic [31:0] p3_rs2_data; // pipe line 3 rs2_data
  logic [31:0] p3_imm; // pipe line 3 immediate
  logic [31:0] p3_csr_data; // pipe line 3 csr data
  logic [11:0] p3_csr_addr; // pipe line 3 CSR address
  logic [4:0] p3_rd; // pipe line 3 destination register
  logic [4:0] p3_rs2; // source register 3
  mem_op_e p3_mem_op; // pipe line 3 memory write enable
  wb_from_e p3_wb_from; // pipe line 3 write back from
  ram_mask_e p3_ram_mask; // pipe line 3 reg mask
  reg_mask_e p3_reg_mask; // pipe line 3 reg mask
  reg_we_e p3_r_we; // pipe line 3 register write enable
  reg_we_e p3_csr_we; // pipe line 3 CSR write enable
  logic p3_valid = 0; // pipe line 3 valid
  pc_input_type_e p3_pc_input_type = PC_INPUT_NEXT; // pipe line 3 PC INPUT
  branch_type_e p3_branch_type; // pipe line 3 branch type

  always_ff @(posedge clk) begin
    p3_pc <= p2_pc;
    p3_alu_result <= alu_result;
    p3_rs2_data <= forwarding_rs2_data;
    p3_rs2 <= p2_rs2;
    p3_imm <= p2_imm;
    p3_csr_data <= p2_csr_data;
    p3_rd <= p2_rd;
    p3_csr_addr <= p2_csr_addr;
    p3_mem_op <= p2_mem_op;
    p3_wb_from <= p2_wb_from;
    p3_ram_mask <= p2_ram_mask;
    p3_reg_mask <= p2_reg_mask;
    p3_r_we <= p2_r_we;
    p3_csr_we <= p2_csr_we;
    p3_valid <= p2_valid & !loaduse;
    p3_pc_input_type <= p2_pc_input_type;
    p3_branch_type <= branch_type;
  end

  // pipe line 4
  logic [31:0] p4_pc = 0; // pipe line 4 pc
  logic [31:0] p4_alu_result; // pipe line 4 alu result
  logic [31:0] p4_imm; // pipe line 4 immediate
  logic [31:0] p4_ram_out; // pipe line 4 ram output
  logic [31:0] p4_csr_data; // pipe line 4 csr data
  logic [11:0] p4_csr_addr; // pipe line 4 CSR address
  logic [4:0] p4_rd; // pipe line 4 destination register
  mem_op_e p4_mem_op; // pipe line 4 memory write enable
  wb_from_e p4_wb_from; // pipe line 4 write back from
  ram_mask_e p4_ram_mask; // pipe line 4 reg mask
  reg_mask_e p4_reg_mask; // pipe line 4 reg mask
  reg_we_e p4_r_we; // pipe line 4 register write enable
  reg_we_e p4_csr_we; // pipe line 4 CSR write enable
  logic p4_valid = 0; // pipe line 4 valid
  pc_input_type_e p4_pc_input_type = PC_INPUT_NEXT; // pipe line 4 PC INPUT
  branch_type_e p4_branch_type; // pipe line 4 branch type

  always_ff @(posedge clk) begin
    p4_pc <= p3_pc;
    p4_alu_result <= p3_alu_result;
    p4_imm <= p3_imm;
    p4_ram_out <= ram_out;
    p4_csr_data <= p3_csr_data;
    p4_rd <= p3_rd;
    p4_csr_addr <= p3_csr_addr;
    p4_mem_op <= p3_mem_op;
    p4_wb_from <= p3_wb_from;
    p4_ram_mask <= p3_ram_mask;
    p4_reg_mask <= p3_reg_mask;
    p4_r_we <= p3_r_we;
    p4_csr_we <= p3_csr_we;
    p4_valid <= p3_valid;
    p4_pc_input_type <= p3_pc_input_type;
    p4_branch_type <= p3_branch_type;
  end

  reg_mask reg_mask0 (
    // -- Inputs
    .data(reg_wb),
    .reg_mask_type(p4_reg_mask),
    // -- Outputs
    .masked_data(masked_reg_wb)
  );

  reg_mask reg_mask1 (
    // -- Inputs
    .data(p3_alu_result),
    .reg_mask_type(p3_reg_mask),
    // -- Outputs
    .masked_data(masked_alu_result)
  );

  // ID Stage  
  decoder decoder0 (
    // -- Inputs
    .instr(p1_instr),
    // -- Outputs
    .rs1,
    .rs2,
    .rd,
    .imm,
    .alu_op,
    .pc_input_type,
    .alu_input1_type,
    .alu_input2_type,
    .wb_from,
    .reg_mask,
    .ram_mask,
    .r_we,
    .mem_op,
    .csr_we
  );

  registers registers0 (
    // -- Inputs
    .clk,
    .we((p4_r_we == REG_WE & p4_valid ) ? REG_WE : REG_WD),
    .rs1_addr(rs1),
    .rs2_addr(rs2),
    .rd_addr(p4_rd),
    .rd_data(masked_reg_wb),
    // -- Outputs
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
  );

  csr_registers csr_registers0 (
    // -- Inputs
    .clk,
    .we((p4_csr_we == REG_WE & p4_valid) ? REG_WE : REG_WD),
    .csr_addr(csr_addr),
    .csr_waddr(p4_csr_addr),
    .wdata(p4_alu_result),
    // -- Outputs
    .data(csr_data)
  );

  assign alu_input1 = alu_input1_type == ALU_INPUT1_IMM ? imm :
                      alu_input1_type == ALU_INPUT1_RS1 ? rs1_data :
                      alu_input1_type == ALU_INPUT1_PC ? p1_pc : 
                      alu_input1_type == ALU_INPUT1_CSR ? csr_data : 
                      32'b0;
  assign alu_input2 = alu_input2_type == ALU_INPUT2_IMM ? imm :
                      alu_input2_type == ALU_INPUT2_RS1 ? rs1_data : 
                      alu_input2_type == ALU_INPUT2_RS2 ? rs2_data : 
                      32'b0;

  assign forwarding_alu_input1 = (
    p2_alu_input1_type == ALU_INPUT1_RS1 & 
    p3_forwarding & 
    p3_rd == p2_rs1 &
    p3_wb_from == WB_ALU &
    |p3_rd
  ) ? masked_alu_result : 
  (
    p2_alu_input1_type == ALU_INPUT1_RS1 & 
    p4_forwarding & 
    p4_rd == p2_rs1 &
    (p4_wb_from == WB_ALU || p4_wb_from == WB_MEM) &
    |p4_rd
  ) ? masked_reg_wb : 
  (
    p2_alu_input1_type == ALU_INPUT1_CSR &
    p3_csr_addr == p2_csr_addr 
  ) ? p3_csr_data :
  (
    p2_alu_input1_type == ALU_INPUT1_CSR &
    p4_csr_addr == p2_csr_addr 
  ) ? p4_csr_data : p2_alu_input1;

  assign forwarding_alu_input2 = (
    p2_alu_input2_type == ALU_INPUT2_RS1 & 
    p3_forwarding & 
    p3_rd == p2_rs1 &
    p3_wb_from == WB_ALU &
    |p3_rd
  ) ? masked_alu_result : (
    p2_alu_input2_type == ALU_INPUT2_RS1 & 
    p4_forwarding & 
    p4_rd == p2_rs1 &
    (p4_wb_from == WB_ALU || p4_wb_from == WB_MEM) &
    |p4_rd
  ) ? masked_reg_wb : (
    p2_alu_input2_type == ALU_INPUT2_RS2 &
    p3_forwarding & 
    p3_rd == p2_rs2 &
    p3_wb_from == WB_ALU &
    |p3_rd
  ) ? masked_alu_result : (
    p2_alu_input2_type == ALU_INPUT2_RS2 &
    p4_forwarding & 
    p4_rd == p2_rs2 &
    (p4_wb_from == WB_ALU || p4_wb_from == WB_MEM) &
    |p4_rd
  ) ? masked_reg_wb : p2_alu_input2;

  assign forwarding_rs2_data = (
    p3_forwarding &
    p3_rd == p2_rs2 &
    p4_wb_from == WB_ALU &
    |p3_rd
  ) ? masked_alu_result : (
    p4_forwarding &
    p4_rd == p2_rs2 &
    (p4_wb_from == WB_ALU || p4_wb_from == WB_MEM) &
    |p4_rd
  ) ? masked_reg_wb : p2_rs2_data;

  // EX Stage
  alu alu0 (
    // -- Inputs
    .data1(forwarding_alu_input1),
    .data2(forwarding_alu_input2),
    .alu_op(p2_alu_op),
    // -- Outputs
    .result(alu_result),
    .branch_type(branch_type)
  );


  // MA Stage
  ram ram0 (
    // -- Inputs
    .clk,
    .addr1(p3_alu_result),
    .addr2(ram_addr2),
    .wdata(p3_rs2_data),
    // .wdata((p4_forwarding & p4_rd == p3_rs2 & |p4_rd) ? masked_reg_wb  : p3_rs2_data),
    .mem_op(p3_valid ? p3_mem_op : MEM_LOAD),
    .ram_mask(p3_ram_mask),
    // -- Outputs
    .rdata1(ram_out),
    .rdata2(ram_out2)
  );


  // WB Stage
  assign reg_wb = p4_wb_from == WB_ALU ? p4_alu_result :
                  p4_wb_from == WB_PC ? p4_pc + 4 :
                  p4_wb_from == WB_MEM ? p4_ram_out :
                  p4_wb_from == WB_CSR ? p4_csr_data :
                  32'b0;


  // logic psram_read_avail;
  // logic psram_busy;
  // logic [15:0] psram_out; // psram output

  // psram psram0 (
  //     .clk(clk),

  //     .bank_sel(0),
  //     // Remove bottom most bit, since this is a 8bit address and the RAM wants a 16bit address
  //     .addr(alu_result[22:1]),

  //     .write_en(mem_op == MEM_STORE ? 1'b1 : 1'b0),
  //     .data_in(rs2_data[15:0]),
  //     .write_high_byte(alu_result[0]),
  //     .write_low_byte(~alu_result[0]),

  //     .read_en (mem_op == MEM_LOAD ? 1'b1 : 1'b0),
  //     .read_avail(psram_read_avail),
  //     .data_out(psram_out),
  //     .busy(psram_busy),

  //     // Actual PSRAM interface
  //     .cram_a(cram0_a),
  //     .cram_dq(cram0_dq),
  //     .cram_wait(cram0_wait),
  //     .cram_clk(cram0_clk),
  //     .cram_adv_n(cram0_adv_n),
  //     .cram_cre(cram0_cre),
  //     .cram_ce0_n(cram0_ce0_n),
  //     .cram_ce1_n(cram0_ce1_n),
  //     .cram_oe_n(cram0_oe_n),
  //     .cram_we_n(cram0_we_n),
  //     .cram_ub_n(cram0_ub_n),
  //     .cram_lb_n(cram0_lb_n)
  // );


endmodule

`endif
