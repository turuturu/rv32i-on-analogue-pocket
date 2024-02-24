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
#include <memory>
#include <cstdio>
#include <iomanip> // std::setfill, std::setwを使用するために必要

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
        // バイナリファイルを開く
        std::ifstream file(BASE_PATH + filename, std::ios::binary);
        if (!file) {
            std::cerr << "ファイルを開けませんでした。" << std::endl;
            return 1;
        }
        // ファイルの終わりまで読み込む
        int i = 0;
        while (!file.eof()) {
            uint32_t value;
            file.read(reinterpret_cast<char*>(&value), sizeof(value));
            // ファイルから正しく読み込めたか確認
            if (file.gcount() == sizeof(value)) {
                dut->rv32i_top->rom0->inner_rom[i/4] = value;
            }
            i += 4;
        }
        for(int j = 0; j < i/4; j++){
            std::cout << std::setfill('0') << std::setw(8) << std::hex << dut->rv32i_top->rom0->inner_rom[j] << std::endl;
        }

        return i / 4;
    }

    void run_test(std::string filename){
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        Verilated::traceEverOn(true);
        std::string vcd_name = "vcd/" + filename + ".vcd";
        std::string bin_name = filename + ".bin";
        dut->trace(tfp, 1000);
        tfp->open(vcd_name.c_str());

        int len = load_binary_to_rom(bin_name.c_str());
        ASSERT_EQ(dut->rv32i_top->rom0->inner_rom[0], 0x0500006f);
        ASSERT_EQ(dut->rv32i_top->rom0->inner_rom[1], 0x34202f73);
//        ASSERT_EQ(dut->rv32i_top->rom0->inner_rom[80], 0x00000093);
        int cnt = 0;
        dut->clk = 0;
        dut->reset_n = 0;
        dut->eval();
        dut->clk = 1;
        dut->eval();
        dut->clk = 0;
        dut->eval();
        tfp->dump(cnt++);
        for(int i = 0; i < len; i++){
            dut->clk = 1;
            dut->eval();
            tfp->dump(cnt++);
            dut->reset_n = 1;
            dut->clk = 0;
            dut->eval();
            tfp->dump(cnt++);
        }
        dut->final();
        tfp->close();
        ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
    }

};

namespace {

TEST_F(Rv32iTopTest, rv32ui_p_add) {
    run_test("rv32ui-p-add");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
} 

}  // namespace

