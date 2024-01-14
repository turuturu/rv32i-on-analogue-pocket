#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_csr_alu.h"
#include "Vrv32i_csr_alu_rv32i.h"

#include <climits>
#include <random>

class CsrAluTest : public ::testing::Test {
   protected:
    Vrv32i_csr_alu *dut;

    void SetUp() override { dut = new Vrv32i_csr_alu(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(CsrAluTest, CSRRW) {
    dut->eval();
} 


}  // namespace

