#include <gtest/gtest.h>
#include <verilated.h>
#include "test_rv32i_alu.dir/Valu.dir/Valu.h"
#include "test_rv32i_alu.dir/Valu.dir/Valu_rv32i.h"

#include <climits>
#include <random>

class AluTest : public ::testing::Test {
   protected:
    Valu *dut;

    void SetUp() override { dut = new Valu(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(AluTest, JAL) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000002;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_JAL;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000000);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);
} 

TEST_F(AluTest, JALR) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000002;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_JALR;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000002);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_ABSOLUTE);
} 
TEST_F(AluTest, BEQ) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BEQ;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);

    dut->data1 = 0x00000000;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BEQ;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
} 
TEST_F(AluTest, BNE) {
    dut->data1 = 0x00000000;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BNE;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);

    dut->data1 = 0x00000001;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BNE;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}
TEST_F(AluTest, BLT) {
    dut->data1 = 0x00000000;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BLT;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);

    dut->data1 = 0x00000001;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BLT;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0xffffffff;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BLT;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);


}

TEST_F(AluTest, BGE) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BGE;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);

    dut->data1 = 0x00000002;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BGE;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);

    dut->data1 = 0x00000000;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BGE;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000001;
    dut->data2 = 0xffffffff;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BGE;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);
}

TEST_F(AluTest, BLTU) {
    dut->data1 = 0x00000000;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BLTU;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);

    dut->data1 = 0x00000001;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BLTU;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000001;
    dut->data2 = 0xffffffff;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BLTU;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);
}
TEST_F(AluTest, BGEU) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BGEU;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);

    dut->data1 = 0x00000002;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BGEU;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);

    dut->data1 = 0x00000000;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BGEU;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0xffffffff;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_BGEU;
    dut->eval();
    ASSERT_EQ(dut->result, 0);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_RELATIVE);
}
TEST_F(AluTest, ADD) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000002;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_ADD;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000003);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
} 
TEST_F(AluTest, SUB) {
    dut->data1 = 0x00000003;
    dut->data2 = 0x00000002;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SUB;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000001);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}
TEST_F(AluTest, SLL) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000002;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SLL;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000004);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}
TEST_F(AluTest, SLT) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000002;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SLT;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000001);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000002;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SLT;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000000);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0xffffffff;
    dut->data2 = 0x00000002;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SLT;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000001);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}
TEST_F(AluTest, SLTU) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000002;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SLTU;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000001);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000002;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SLTU;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000000);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000001;
    dut->data2 = 0xffffffff;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SLTU;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000001);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}
TEST_F(AluTest, XOR) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_XOR;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000000);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000001;
    dut->data2 = 0x00000000;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_XOR;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000001);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}
TEST_F(AluTest, SRL) {
    dut->data1 = 0x00000004;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SRL;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000002);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0xffffffff;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SRL;
    dut->eval();
    ASSERT_EQ(dut->result, 0x7fffffff);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}
TEST_F(AluTest, SRA) {
    dut->data1 = 0x00000004;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SRA;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000002);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0xffffffff;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_SRA;
    dut->eval();
    ASSERT_EQ(dut->result, 0xffffffff);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}

TEST_F(AluTest, OR) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_OR;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000001);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000000;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_OR;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000001);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000000;
    dut->data2 = 0x00000000;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_OR;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000000);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

}
TEST_F(AluTest, AND) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_AND;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000001);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000000;
    dut->data2 = 0x00000001;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_AND;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000000);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);

    dut->data1 = 0x00000000;
    dut->data2 = 0x00000000;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_AND;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000000);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}
TEST_F(AluTest, NOP) {
    dut->data1 = 0x00000001;
    dut->data2 = 0x00000002;
    dut->alu_op = Valu_rv32i::alu_op_e::ALU_NOP;
    dut->eval();
    ASSERT_EQ(dut->result, 0x00000000);
    ASSERT_EQ(dut->branch_type, Valu_rv32i::branch_type_e::BRANCH_NONE);
}
}  // namespace

