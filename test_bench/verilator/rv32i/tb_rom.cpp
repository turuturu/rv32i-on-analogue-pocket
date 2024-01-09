#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_rom.h"
#include "Vrv32i_rom_rom.h"
#include "Vrv32i_rom_rv32i.h"

#include <climits>
#include <random>

class RomTest : public ::testing::Test {
   protected:
    Vrv32i_rom *dut;

    void SetUp() override { dut = new Vrv32i_rom(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(RomTest, READ_WRITE) {
    uint32_t vals[] = {
        0x00000001,
        0x00000002,
        0x00000003,
        0x00000004,
    };
    int length = sizeof(vals);
    int i = 0;
    
    while(i < length) {
        dut->rom->innerrom[i] = vals[i];
        i++;
    }
//   ASSERT_EQ(dut->rom[4], 0x00000001);
    dut->clk = 0;
    i = 0;
    while(i < length) {
        dut->clk = 0;
        dut->eval();
        dut->clk = 1;
        dut->addr = i * 4;
        dut->eval();
        ASSERT_EQ(vals[i], dut->data);
        i++;
    }
    // dut->eval();
} 

}  // namespace

