#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_rom.h"
#include "Vrv32i_rom_rom.h"
#include "Vrv32i_rom_rv32i.h"

#include <climits>
#include <random>
#include <bitset>

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
    size_t length = sizeof(vals) / sizeof(vals[0]);

    int i = 0;
    
    while(i < length) {
        dut->rom->inner_rom[i] = vals[i];
        i++;
    }

    dut->clk = 0;
    i = 0;
    std::cout << length << std::endl;

    while(i < length) {
        dut->clk = 0;
        dut->eval();
        dut->clk = 1;
        dut->re = 1;
        dut->addr = i * 4;
        dut->eval();
        if(dut->oe == 1){
            // ASSERT_EQ(i, dut->rom->inner_addr);
            ASSERT_EQ(vals[0], (uint32_t)dut->data[0]);
            dut->re = 0;
            i++;
        }
    }
    // dut->eval();
} 

}  // namespace

