#include "tb_decoder.hpp"

#include <gtest/gtest.h>
#include <verilated.h>
#include "Valu___024unit.h"

#include <climits>
#include <random>

void ValuDecoder::exec(const int &_instr) {
    instr = _instr;
    eval();
}

class TestDecoder : public ::testing::Test {
   protected:
    TestDecoder() : instr(0) {};
    ValuDecoder *dut;

    int instr;

    void SetUp() override { dut = new ValuDecoder(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(TestDecoder, LUI) {
    instr = 0b0000'0000'0000'0000'0000'0000'0011'0111;
    dut->exec(instr);
    ASSERT_EQ(dut->alu_op, Valu___024unit::alu_op_e::RV_ALU_LUI);
} 

}  // namespace

