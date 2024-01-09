#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_ram.h"
#include "Vrv32i_ram_rv32i.h"

#include <climits>
#include <random>

class RamTest : public ::testing::Test {
   protected:
    Vrv32i_ram *dut;

    void SetUp() override { dut = new Vrv32i_ram(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(RamTest, LUI) {
    int instr = 0b0000'0000'0000'0000'0000'0000'0011'0111;
    // dut->instr = instr;
    // dut->eval();
    // ASSERT_EQ(dut->alu_op, Valu_rv32i::alu_op_e::ALU_ADD);
} 

}  // namespace

