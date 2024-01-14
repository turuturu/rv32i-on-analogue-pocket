#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_csr_alu.h"
#include "Vrv32i_csr_alu_rv32i.h"

#include <climits>
#include <random>

class CsrAluTest : public ::testing::Test {
   protected:
    Vrv32i_csr_alu *dut;

    void SetUp() override { dut = new Vrv32i_csr_alu(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(CsrAluTest, CSRRW) {
    uint32_t csr_data = 0x00000001;
    uint32_t data     = 0x00000002;
    dut->csr_data = csr_data;
    dut->data     = data;
    dut->csr_op   = Vrv32i_csr_alu_rv32i::csr_op_e::CSR_RW;
    dut->eval();
    ASSERT_EQ(dut->result, data);
}
TEST_F(CsrAluTest, CSRRS) {
    uint32_t csr_data = 0x00000001;
    uint32_t data     = 0x00000002;
    dut->csr_data = csr_data;
    dut->data     = data;
    dut->csr_op   = Vrv32i_csr_alu_rv32i::csr_op_e::CSR_RS;
    dut->eval();
    ASSERT_EQ(dut->result, csr_data | data);
}
TEST_F(CsrAluTest, CSRRC) {
    uint32_t csr_data = 0x00000001;
    uint32_t data     = 0x00000002;
    dut->csr_data = csr_data;
    dut->data     = data;
    dut->csr_op   = Vrv32i_csr_alu_rv32i::csr_op_e::CSR_RC;
    dut->eval();
    ASSERT_EQ(dut->result, csr_data & (~data));
}

}  // namespace

