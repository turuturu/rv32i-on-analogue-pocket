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
    dut->clk = 0;
    i = 0;
    // read test
    while(i < length) {
        dut->clk = 0;
        dut->eval();
        dut->clk = 1;
        dut->addr = i << 2; // addr is aligned to 4 bytes
        dut->mem_op = Vrv32i_ram_rv32i::MEM_LOAD;
        dut->eval();
        ASSERT_EQ(vals[i], dut->rdata);
        i++;
    }
    // write test
    for(i = 0; i < 100; i++){
        dut->clk = 0;
        dut->eval();
        dut->clk = 1;
        dut->addr = i << 2; // addr is aligned to 4 bytes
        dut->wdata = i * i;
        dut->mem_op = Vrv32i_ram_rv32i::MEM_STORE;
        dut->eval();
        ASSERT_EQ(i * i, dut->ram->inner_ram[i]);
        ASSERT_EQ(i, dut->ram->inner_addr);
        ASSERT_EQ(i * i, dut->rdata);
    }

}
}  // namespace

