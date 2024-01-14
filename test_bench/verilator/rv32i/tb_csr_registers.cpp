#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_csr_registers.h"
#include "Vrv32i_csr_registers_csr_registers.h"
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

TEST_F(CsrRegistersTest, READ_WRITE) {
    int num_registers = 4096;
    for(int i = 0; i < num_registers; i++){
        dut->csr_registers->regs[i] = (uint32_t)i+1;
    }
    int i = 0;
    // read test
    while(i < num_registers) {
        dut->clk = 0;
        dut->we = Vrv32i_csr_registers_rv32i::REG_WD;
        dut->csr_addr = i;
        dut->wdata = (uint32_t)9999;
        dut->eval();
        dut->clk = 1;
        dut->eval();
        ASSERT_EQ(i+1, dut->data);
        i++;
    }
    // write test
    while(i < num_registers) {
        uint32_t val = (i+1)*(i*1);
        dut->clk = 0;
        dut->we = Vrv32i_csr_registers_rv32i::REG_WE;
        dut->csr_addr = i;
        dut->wdata = val;
        dut->eval();
        dut->clk = 1;
        dut->eval();
        ASSERT_EQ(val, dut->data);
        i++;
    }
} 


}  // namespace

