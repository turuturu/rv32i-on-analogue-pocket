#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_ram_mask.h"
#include "Vrv32i_ram_mask_rv32i.h"

#include <climits>
#include <random>

class RamMaskTest : public ::testing::Test {
   protected:
    Vrv32i_ram_mask *dut;

    void SetUp() override { dut = new Vrv32i_ram_mask(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(RamMaskTest, READ_WRITE) {
    // dut->eval();
} 

}  // namespace

