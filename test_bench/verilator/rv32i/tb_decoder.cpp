#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_decoder.h"
#include "Vrv32i_decoder_decoder.h"
#include "Vrv32i_decoder_rv32i.h"

#include <iostream>
#include <bitset>
#include <climits>
#include <random>

class DecoderTest : public ::testing::Test {
   protected:
    Vrv32i_decoder *dut;

    void SetUp() override { dut = new Vrv32i_decoder(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

uint32_t getRtypeInst(uint32_t rs1, uint32_t rs2, uint32_t rd, uint32_t funct3, uint32_t funct7, uint32_t opcode){
    uint32_t _rs1 = rs1 & 0b11111; // 5bit
    uint32_t _rs2 = rs2 & 0b11111; // 5bit
    uint32_t _rd = rd & 0b11111; // 5bit
    uint32_t _funct3 = funct3 & 0b111; // 3bit
    uint32_t _funct7 = funct7 & 0b1111111; // 7bit
    uint32_t _opcode = opcode & 0b1111111; // 7bit
    return (_funct7 << 25) | (_rs2 << 20) | (_rs1 << 15) | (_funct3 << 12 ) | (_rd << 7) | _opcode;
}

uint32_t getItypeInst(uint32_t imm, uint32_t rs1, uint32_t rd, uint32_t funct3, uint32_t opcode){
    uint32_t _imm = imm & 0b111111111111; // 12bit
    uint32_t _rs1 = rs1 & 0b11111; // 5bit
    uint32_t _rd = rd & 0b11111; // 5bit
    uint32_t _funct3 = funct3 & 0b111; // 3bit
    uint32_t _opcode = opcode & 0b1111111; // 7bit
    return (_imm << 20) | (_rs1 << 15) | (_funct3 << 12 ) | (_rd << 7) | _opcode;

}

uint32_t getStypeInst(uint32_t imm, uint32_t rs1, uint32_t rs2, uint32_t funct3, uint32_t opcode){
    uint32_t _imm = imm & 0b111111111111; // 12bit
    uint32_t _rs1 = rs1 & 0b11111; // 5bit
    uint32_t _rs2 = rs2 & 0b11111; // 5bit
    uint32_t _funct3 = funct3 & 0b111; // 3bit
    uint32_t _opcode = opcode & 0b1111111; // 7bit
    return ((_imm >> 5) & 0b1111111 << 25) | (_rs2 << 20) | (_rs1 << 15) | (_funct3 << 12 ) | ((imm & 0x11111) << 7) | _opcode;
}

uint32_t getBtypeInst(uint32_t imm, uint32_t rs1, uint32_t rs2, uint32_t funct3, uint32_t opcode){
    uint32_t _imm = imm & 0b1111111111111; // 13bit
    uint32_t _rs1 = rs1 & 0b11111; // 5bit
    uint32_t _rs2 = rs2 & 0b11111; // 5bit
    uint32_t _funct3 = funct3 & 0b111; // 3bit
    uint32_t _opcode = opcode & 0b1111111; // 7bit
    return (((imm >> 12) & 1) << 31) | (((imm >> 5) & 0b111111) << 25) | (_rs2 << 20) | (_rs1 << 15) | (_funct3 << 12) | (((_imm >> 1) & 0b1111) << 8) | (((_imm >> 11) & 1) << 7) | _opcode;
}

uint32_t getUtypeInst(uint32_t imm, uint32_t rd, uint32_t opcode){
    uint32_t _rd = rd & 0b11111; // 5bit
    uint32_t _opcode = opcode & 0b1111111; // 7bit
    return (((imm >> 12) & 0b11111111111111111111) << 12)| (_rd << 7) | _opcode;
}

uint32_t getJtypeInst(uint32_t imm, uint32_t rd, uint32_t opcode){
    uint32_t _rd = rd & 0b11111; // 5bit
    uint32_t _opcode = opcode & 0b1111111; // 7bit
    uint32_t conved_imm =  (((imm >> 20) & 1) << 20) | ((imm >> 1) & 0b1111111111) << 9 | ((imm >> 11) & 1) << 8 | ((imm >> 12) & 0b11111111);
    return (conved_imm << 12) | (_rd << 7) | _opcode;
}

TEST_F(DecoderTest, LUI) {
    uint32_t imm = 1 << 12;
    uint32_t rd = 1;
    uint32_t opcode = 0b0110111;
//    int instr = (imm << 12) | (rd << 7) | opcode;
    uint32_t instr = getUtypeInst(imm, rd, opcode);
//    std::cout << "instr = " << std::bitset<32>(instr) << std::endl;
    dut->instr = instr;
    dut->eval();
    ASSERT_EQ(dut->rs1, 0);
    ASSERT_EQ(dut->rs2, 0);
    ASSERT_EQ(dut->rd, rd);
    ASSERT_EQ(dut->imm, imm);
    ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_IMM);
    ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_NONE);
    ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_ALU);
    ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WE);
    ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
    ASSERT_EQ(dut->alu_op, Vrv32i_decoder_rv32i::alu_op_e::ALU_ADD);
    ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::UTYPE);
}

TEST_F(DecoderTest, AUIPC) {
    uint32_t rd = 1;
    uint32_t imm = 2 << 12;
    uint32_t opcode = 0b0010111;
    //int instr =  (imm << 12) | (rd << 7) | opcode;
    uint32_t instr = getUtypeInst(imm, rd, opcode);

    dut->instr = instr;
    dut->eval();
    ASSERT_EQ(dut->rs1, 0);
    ASSERT_EQ(dut->rs2, 0);
    ASSERT_EQ(dut->rd, rd);
    ASSERT_EQ(dut->imm, imm);
    ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_PC);
    ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_IMM);
    ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_ALU);
    ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WE);
    ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
    ASSERT_EQ(dut->alu_op, Vrv32i_decoder_rv32i::alu_op_e::ALU_ADD);
    ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::UTYPE);
}

TEST_F(DecoderTest, JAL) {
    uint32_t rd = 1;
    uint32_t imm = 7;
    uint32_t opcode = 0b1101111;
    uint32_t instr = getJtypeInst(imm, rd, opcode);
    dut->instr = instr;
    dut->eval();
    ASSERT_EQ(dut->rs1, 0);
    ASSERT_EQ(dut->rs2, 0);
    ASSERT_EQ(dut->rd, rd);
    ASSERT_EQ(dut->imm, ((imm >> 1 ) << 1));
    ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_PC);
    ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_IMM);
    ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_PC);
    ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WE);
    ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
        ASSERT_EQ(dut->alu_op, Vrv32i_decoder_rv32i::alu_op_e::ALU_JAL);
    ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::JTYPE);
}

TEST_F(DecoderTest, JALR) {
    uint32_t imm = 1;
    uint32_t rs1 = 1;
    uint32_t funct3 = 0;
    uint32_t rd = 1;
    uint32_t opcode = 0b1100111;
    uint32_t instr = getItypeInst(imm, rs1, rd, funct3, opcode);
    // std::cout << "instr = " << std::bitset<32>(instr) << std::endl;
    dut->instr = instr;
    dut->eval();
    ASSERT_EQ(dut->rs1, rs1);
    ASSERT_EQ(dut->rs2, 0);
    ASSERT_EQ(dut->rd, rd);
    ASSERT_EQ(dut->imm, imm);
    ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_RS1);
    ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_IMM);
    ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_PC);
    ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WE);
    ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
    ASSERT_EQ(dut->alu_op, Vrv32i_decoder_rv32i::alu_op_e::ALU_JALR);
    ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::ITYPE);
}

TEST_F(DecoderTest, BRANCH) {
    uint32_t imm = 2;
    uint32_t rs1 = 1;
    uint32_t rs2 = 1;
    uint32_t opcode = 0b1100011;
    uint32_t funct3_arr[] = {
        0b000, // BEQ
        0b001, // BNE
        0b100, // BLT
        0b101, // BGE
        0b110, // BLTU
        0b111  // BGEU
    };
    uint32_t alu_op_arr[] = {
        Vrv32i_decoder_rv32i::alu_op_e::ALU_BEQ,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_BNE,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_BLT,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_BGE,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_BLTU,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_BGEU,
    }; // BEQ, BNE, BLE, BGE, BLTU, BGEU
    int length = sizeof(funct3_arr)  / sizeof(int);
    for(int i = 0; i < length; i++){
        uint32_t funct3 = funct3_arr[i];
        uint32_t alu_op = alu_op_arr[i];
        uint32_t instr = getBtypeInst(imm, rs1, rs2, funct3, opcode);
        dut->instr = instr;
        dut->eval();
        ASSERT_EQ(dut->rs1, rs1);
        ASSERT_EQ(dut->rs2, rs2);
        ASSERT_EQ(dut->rd, 0);
        ASSERT_EQ(dut->imm, imm);
        ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_RS1);
        ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_RS2);
        ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_NONE);
        ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WD);
        ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
        ASSERT_EQ(dut->alu_op, alu_op);
        ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::BTYPE);
    }
}

TEST_F(DecoderTest, LOAD) {
    uint32_t imm = 1;
    uint32_t rs1 = 1;
    uint32_t rd = 1;
    uint32_t opcode = 0b0000011;
    uint32_t funct3_arr[] = {
        0b000, // LB
        0b001, // LH
        0b010, // LW
        0b100, // LBU
        0b101, // LHU
    };
    int length = sizeof(funct3_arr)  / sizeof(int);
    for(int i = 0; i < length; i++){
        uint32_t funct3 = funct3_arr[i];
        uint32_t instr = getItypeInst(imm, rs1, rd, funct3, opcode);
        dut->instr = instr;
        dut->eval();
        ASSERT_EQ(dut->rs1, rs1);
        ASSERT_EQ(dut->rs2, 0);
        ASSERT_EQ(dut->rd, rd);
        ASSERT_EQ(dut->imm, imm);
        ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_RS1);
        ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_IMM);
        ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_MEM);
        ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WE);
        ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
        ASSERT_EQ(dut->alu_op, Vrv32i_decoder_rv32i::alu_op_e::ALU_ADD);
        ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::ITYPE);
    }
}

TEST_F(DecoderTest, STORE) {
    uint32_t imm = 1;
    uint32_t rs1 = 1;
    uint32_t rs2 = 2;
    uint32_t opcode = 0b0100011;
    uint32_t funct3_arr[] = {
        0b000, // SB
        0b001, // SH
        0b010, // SW
    };
    int length = sizeof(funct3_arr)  / sizeof(int);
    for(int i = 0; i < length; i++){
        uint32_t funct3 = funct3_arr[i];
        uint32_t instr = getStypeInst(imm, rs1, rs2, funct3, opcode);
        dut->instr = instr;
        dut->eval();
        ASSERT_EQ(dut->rs1, rs1);
        ASSERT_EQ(dut->rs2, rs2);
        ASSERT_EQ(dut->rd, 0);
        ASSERT_EQ(dut->imm, imm);
        ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_RS1);
        ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_IMM);
        ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_NONE);
        ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WD);
        ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_STORE);
        ASSERT_EQ(dut->alu_op, Vrv32i_decoder_rv32i::alu_op_e::ALU_ADD);
        ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::STYPE);
    }
}

TEST_F(DecoderTest, OPIMM) {
    uint32_t imm = 0xff;
    uint32_t rs1 = 1;
    uint32_t rd = 2;
    uint32_t opcode = 0b0010011;
    uint32_t funct3_arr[] = {
        0b000, // ADDI 
        0b010, // SLTI
        0b011, // SLTIU
        0b100, // XORI
        0b110, // ORI
        0b111, // ANDI
        0b001, // SLLI
    };
    uint32_t alu_op_arr[] = {
        Vrv32i_decoder_rv32i::alu_op_e::ALU_ADD,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_SLT,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_SLTU,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_XOR,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_OR,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_AND,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_SLL,
    };
    uint32_t instr;
    uint32_t funct3;
    uint32_t alu_op;
    int length = sizeof(funct3_arr)  / sizeof(int);
    for(int i = 0; i < length; i++){
        funct3 = funct3_arr[i];
        alu_op = alu_op_arr[i];
        instr = getItypeInst(imm, rs1, rd, funct3, opcode);
        dut->instr = instr;
        dut->eval();
        // std::cout << "instr = " << std::bitset<32>(instr) << std::endl;
        ASSERT_EQ(dut->rs1, rs1);
        ASSERT_EQ(dut->rs2, 0);
        ASSERT_EQ(dut->rd, rd);
        ASSERT_EQ(dut->imm, imm);
        ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_RS1);
        ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_IMM);
        ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_ALU);
        ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WE);
        ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
        ASSERT_EQ(dut->alu_op, alu_op);
        ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::ITYPE);
    }
    funct3 = 0b101;
    imm = 0b000000000001;
    instr = getItypeInst(imm, rs1, rd, funct3, opcode);
    dut->instr = instr;
    dut->eval();
    ASSERT_EQ(dut->rs1, rs1);
    ASSERT_EQ(dut->rs2, 0);
    ASSERT_EQ(dut->rd, rd);
    ASSERT_EQ(dut->imm, imm);
    ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_RS1);
    ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_IMM);
    ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_ALU);
    ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WE);
    ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
    ASSERT_EQ(dut->alu_op, Vrv32i_decoder_rv32i::alu_op_e::ALU_SRL);
    ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::ITYPE);

    funct3 = 0b101;
    imm = 0b010000000001;
    instr = getItypeInst(imm, rs1, rd, funct3, opcode);
    dut->instr = instr;
    dut->eval();
    ASSERT_EQ(dut->rs1, rs1);
    ASSERT_EQ(dut->rs2, 0);
    ASSERT_EQ(dut->rd, rd);
    ASSERT_EQ(dut->imm, imm);
    ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_RS1);
    ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_IMM);
    ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_ALU);
    ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WE);
    ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
    ASSERT_EQ(dut->alu_op, Vrv32i_decoder_rv32i::alu_op_e::ALU_SRA);
    ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::ITYPE);
}

TEST_F(DecoderTest, OP) {
    uint32_t imm = 0xff;
    uint32_t rs1 = 1;
    uint32_t rs2 = 2;
    uint32_t rd = 2;
    uint32_t opcode = 0b0110011;
    uint32_t funct3_arr[] = {
        0b000, // ADD
        0b000, // SUB
        0b001, // SLL
        0b010, // SLT
        0b011, // SLTU
        0b100, // XOR
        0b101, // SRL
        0b101, // SRA
        0b110, // OR
        0b111, // AND
    };
    uint32_t funct7_arr[] = {
        0b0000000, // ADD
        0b0100000, // SUB
        0b0000000, // SLL
        0b0000000, // SLT
        0b0000000, // SLTU
        0b0000000, // XOR
        0b0000000, // SRL
        0b0100000, // SRA
        0b0000000, // OR
        0b0000000, // AND
    };
    uint32_t alu_op_arr[] = {
        Vrv32i_decoder_rv32i::alu_op_e::ALU_ADD,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_SUB,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_SLL,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_SLT,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_SLTU,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_XOR,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_SRL,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_SRA,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_OR,
        Vrv32i_decoder_rv32i::alu_op_e::ALU_AND,
    };
    uint32_t instr;
    uint32_t funct3;
    uint32_t funct7;
    uint32_t alu_op;
    int length = sizeof(funct3_arr)  / sizeof(int);
    for(int i = 0; i < length; i++){
        funct3 = funct3_arr[i];
        funct7 = funct7_arr[i];
        alu_op = alu_op_arr[i];
        instr = getRtypeInst(rs1, rs2, rd, funct3, funct7, opcode);
        dut->instr = instr;
        dut->eval();
        // std::cout << "instr = " << std::bitset<32>(instr) << std::endl;
        ASSERT_EQ(dut->rs1, rs1);
        ASSERT_EQ(dut->rs2, rs2);
        ASSERT_EQ(dut->rd, rd);
        ASSERT_EQ(dut->imm, 0);
        ASSERT_EQ(dut->alu_input1_type, Vrv32i_decoder_rv32i::alu_input1_type_e::ALU_INPUT1_RS1);
        ASSERT_EQ(dut->alu_input2_type, Vrv32i_decoder_rv32i::alu_input2_type_e::ALU_INPUT2_RS2);
        ASSERT_EQ(dut->wb_from, Vrv32i_decoder_rv32i::wb_from_e::WB_ALU);
        ASSERT_EQ(dut->r_we, Vrv32i_decoder_rv32i::reg_we_e::REG_WE);
        ASSERT_EQ(dut->mem_op, Vrv32i_decoder_rv32i::mem_op_e::MEM_LOAD);
        ASSERT_EQ(dut->alu_op, alu_op);
        ASSERT_EQ(dut->decoder->optype, Vrv32i_decoder_rv32i::optype_e::RTYPE);
    }
}



}  // namespace

