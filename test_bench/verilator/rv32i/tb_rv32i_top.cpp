#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_rv32i_top.h"
#include "Vrv32i_rv32i_top_rv32i.h"

#include <climits>
#include <random>
#include <iostream>
#include <fstream>

std::string BASE_PATH = "_build/riscv-tests-bin/share/riscv-tests/isa/";
class Rv32iTopTest : public ::testing::Test {
   protected:
    Vrv32i_rv32i_top *dut;

    void SetUp() override { dut = new Vrv32i_rv32i_top(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(Rv32iTopTest, LUI) {
    std::string filename = BASE_PATH + "rv32ui-p-add";
    std::ifstream ifs(filename, std::ios::binary);
    ifs.seekg(0, std::ios::end);
    long long int size = ifs.tellg();
    ifs.seekg(0);

    if (size < 0) {
      std::cout << "Not find file: " << filename << std::endl;
      return;
    }

    char* data = new char[size];
    ifs.read(data, size);

    for (int i = 0; i < size; i++) {
        printf("sx");
        printf("%d", data[i]);
        continue;
    }
    delete data;

    int instr = 0b0000'0000'0000'0000'0000'0000'0011'0111;
//    dut->instr = instr;
    dut->eval();
  //  ASSERT_EQ(dut->alu_op, Valu_rv32i::alu_op_e::ALU_ADD);
} 

}  // namespace

