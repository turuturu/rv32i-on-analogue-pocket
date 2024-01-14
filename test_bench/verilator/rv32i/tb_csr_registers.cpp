#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_csr_registers.h"
#include "Vrv32i_csr_registers_rv32i.h"

#include <climits>
#include <random>

class CsrRegistersTest : public ::testing::Test {
   protected:
    Vrv32i_csr_registers *dut;

    void SetUp() override { dut = new Vrv32i_csr_registers(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(CsrRegistersTest, CSRRW) {
    dut->eval();
} 


}  // namespace

