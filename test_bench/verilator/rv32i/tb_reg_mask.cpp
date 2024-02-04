#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_reg_mask.h"
#include "Vrv32i_reg_mask_rv32i.h"

#include <climits>
#include <random>

class RegMaskTest : public ::testing::Test {
   protected:
    Vrv32i_reg_mask *dut;

    void SetUp() override { dut = new Vrv32i_reg_mask(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(RegMaskTest, READ_WRITE) {
    // dut->eval();
} 

}  // namespace

