#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_registers.h"
#include "Vrv32i_registers_registers.h"
#include "Vrv32i_registers_rv32i.h"

#include <climits>
#include <random>

class RegistersTest : public ::testing::Test {
   protected:
    Vrv32i_registers *dut;

    void SetUp() override { dut = new Vrv32i_registers(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(RegistersTest, READ_WRITE) {
    int num_registers = 16;
    for(int i = 0; i < num_registers; i++){
        dut->registers->regs[i] = (uint32_t)i+1;
    }
    dut->clk = 0;
    int i = 0;
    // read test
    while(i < num_registers) {
        dut->clk = 0;
        dut->rs1_addr = i;
        dut->rs2_addr = i+1;
        dut->we = Vrv32i_registers_rv32i::REG_WD;
        dut->rd_addr = i;
        dut->rd_data = (uint32_t)9999;
        dut->eval();
        dut->clk = 1;
        dut->eval();
        ASSERT_EQ(i == 0 ? 0 : i+1, dut->rs1_data);
        ASSERT_EQ(i+2, dut->rs2_data);
        i += 2;
    }
    // write test
    while(i < num_registers) {
        dut->clk = 0;
        dut->rs1_addr = i;
        dut->rs2_addr = i;
        dut->we = Vrv32i_registers_rv32i::REG_WE;
        dut->rd_addr = i;
        dut->rd_data = (uint32_t)i + 2;
        dut->eval();
        dut->clk = 1;
        dut->eval();
        ASSERT_EQ(i == 0 ? 0 : i+2, dut->rs1_data);
        ASSERT_EQ(i == 0 ? 0 : i+2, dut->rs2_data);
        i += 2;
    }
} 

}  // namespace

