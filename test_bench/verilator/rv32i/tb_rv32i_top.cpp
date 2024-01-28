#include <gtest/gtest.h>
#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <climits>
#include <random>
#include <iostream>
#include <fstream>
#include <string>

#include "Vrv32i_rv32i_top.h"
#include "Vrv32i_rv32i_top_rom.h"
#include "Vrv32i_rv32i_top_registers.h"
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

    int load_binary_to_rom(std::string filename){
        std::ifstream ifs(BASE_PATH + filename, std::ios::binary);
        ifs.seekg(0, std::ios::end);
        long long int size = ifs.tellg();
        ifs.seekg(0);

        if (size < 0) {
          std::cout << "Not find file: " << filename << std::endl;
          return -1;
        }
        char* data = new char[size];
        ifs.read(data, size);
        for (uint32_t i = 0; i < size; i+=4) {
            dut->rv32i_top->rom0->inner_rom[i/4] = data[i] | data[i+1] << 8 | data[i+2] << 16 | data[i+3] << 24;
        }
        delete data;
        return size / 4;
    }
};

namespace {

TEST_F(Rv32iTopTest, rv32ui_p_add) {
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true);
    dut->trace(tfp, 1000);
    tfp->open("./rv32ui_p_add.vcd");

    int cnt = 0;
    int len = load_binary_to_rom("rv32ui-p-add.bin");
    dut->clk = 0;
    dut->eval();
    tfp->dump(cnt++);
    dut->reset_n = 0;
    dut->clk = 1;
    dut->eval();
    tfp->dump(cnt++);

    dut->reset_n = 1;
    for(int i = 0; i < len; i++){
        dut->clk = 0;
        dut->eval();
        tfp->dump(cnt++);
        dut->clk = 1;
        dut->eval();
        tfp->dump(cnt++);
      }
      dut->final();
      tfp->close();
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
  //  ASSERT_EQ(dut->alu_op, Valu_rv32i::alu_op_e::ALU_ADD);
} 

}  // namespace

