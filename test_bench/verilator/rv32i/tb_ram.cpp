#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_ram.h"
#include "Vrv32i_ram_ram.h"
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

TEST_F(RamTest, READ_WRITE) {
    uint32_t vals[] = {
        0x00000001,
        0x00000002,
        0x00000003,
        0x00000004,
    };
    int length = sizeof(vals);
    int i = 0;
    while(i < length) {
        dut->ram->inner_ram[i] = vals[i];
        i++;
    }
}
}  // namespace

