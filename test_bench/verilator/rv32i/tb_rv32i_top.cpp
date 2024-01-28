#include <gtest/gtest.h>
#include <verilated.h>
#include <climits>
#include <random>
#include <iostream>
#include <fstream>
#include "Vrv32i_rv32i_top.h"
#include "Vrv32i_rv32i_top_rom.h"
#include "Vrv32i_rv32i_top_rv32i_top.h"


std::string BASE_PATH = "_build/riscv-tests-bin/";
class Rv32iTopTest : public ::testing::Test {
   protected:
    Vrv32i_rv32i_top *dut;

    void SetUp() override { dut = new Vrv32i_rv32i_top(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }

    void load_binary_to_rom(std::string filename){
        std::ifstream ifs(BASE_PATH + filename, std::ios::binary);
        ifs.seekg(0, std::ios::end);
        long long int size = ifs.tellg();
        ifs.seekg(0);

        if (size < 0) {
          std::cout << "Not find file: " << filename << std::endl;
          return;
        }
        char* data = new char[size];
        ifs.read(data, size);
        for (uint32_t i = 0; i < size; i+=4) {
            dut->rv32i_top->rom0->inner_rom[i/4] = data[i] | data[i+1] << 8 | data[i+2] << 16 | data[i+3] << 24;
        }
        delete data;
    }
};

namespace {

TEST_F(Rv32iTopTest, rv32ui_p_add) {
    load_binary_to_rom("rv32ui-p-add.bin");
    int instr = 0b0000'0000'0000'0000'0000'0000'0011'0111;
    dut->eval();
  //  ASSERT_EQ(dut->alu_op, Valu_rv32i::alu_op_e::ALU_ADD);
} 

}  // namespace

