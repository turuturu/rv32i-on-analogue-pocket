#include <gtest/gtest.h>
#include <verilated.h>
#include "Valu.h"
#include "Valu_rv32i.h"

#include <climits>
#include <random>

class RegistersTest : public ::testing::Test {
   protected:
    Valu *dut;

    void SetUp() override { dut = new Valu(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(RegistersTest, LUI) {
    int instr = 0b0000'0000'0000'0000'0000'0000'0011'0111;
    // dut->instr = instr;
    // dut->eval();
    // ASSERT_EQ(dut->alu_op, Valu_rv32i::alu_op_e::ALU_ADD);
} 

}  // namespace

