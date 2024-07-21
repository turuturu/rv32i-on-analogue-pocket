#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_ram.h"
#include "Vrv32i_ram_ram.h"
#include "Vrv32i_ram_rv32i.h"

#include <climits>
#include <random>
#include <bitset>
#include <iostream>

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
    uint8_t vals[] = {
        1,
        2,
        3,
        4,
    };
    int length = sizeof(vals);
    int i = 0;
    while(i < length) {
        dut->ram->inner_ram0[i] = vals[i];
        dut->ram->inner_ram1[i] = vals[i+1];
        dut->ram->inner_ram2[i] = vals[i+2];
        dut->ram->inner_ram3[i] = vals[i+3];
        i += 4;
        // std::cout << "vals = " << std::bitset<32>(vals[0]) << std::endl;
        // std::cout << "vals = " << std::bitset<32>(vals[1]) << std::endl;
        // std::cout << "vals = " << std::bitset<32>(vals[2]) << std::endl;
        // std::cout << "vals = " << std::bitset<32>(vals[3]) << std::endl;
        // std::cout << "inram0 = " << std::bitset<32>(dut->ram->inner_ram0[0]) << std::endl;
        // std::cout << "inram1 = " << std::bitset<32>(dut->ram->inner_ram1[0]) << std::endl;
        // std::cout << "inram2 = " << std::bitset<32>(dut->ram->inner_ram2[0]) << std::endl;
        // std::cout << "inram3 = " << std::bitset<32>(dut->ram->inner_ram3[0]) << std::endl;
    }
    dut->clk = 0;
    i = 0;
    // read test
    while(i < length) {
        dut->clk = 0;
        dut->eval();
        dut->clk = 1;
        dut->addr = i; // addr is aligned to 4 bytes
        dut->mem_op = Vrv32i_ram_rv32i::MEM_LOAD;
        dut->ram_mask = Vrv32i_ram_rv32i::RAM_MASK_B;
        dut->eval();
        ASSERT_EQ(vals[i], dut->rdata);
        i++;
    }
    // write test
    for(i = 0; i < length; i+=4){
        dut->clk = 0;
        dut->eval();
        dut->clk = 1;
        dut->addr = i; // addr is aligned to 4 bytes
        dut->wdata = i * i;
        dut->mem_op = Vrv32i_ram_rv32i::MEM_STORE;
        dut->ram_mask = Vrv32i_ram_rv32i::RAM_MASK_B;
        dut->eval();
        ASSERT_EQ(i * i, dut->ram->inner_ram0[i]);
        // ASSERT_EQ(i * i, dut->ram->inner_ram1[i]);
        // ASSERT_EQ(i * i, dut->ram->inner_ram2[i]);
        // ASSERT_EQ(i * i, dut->ram->inner_ram3[i]);
        ASSERT_EQ(i * i, dut->rdata);
    }

}
}  // namespace

