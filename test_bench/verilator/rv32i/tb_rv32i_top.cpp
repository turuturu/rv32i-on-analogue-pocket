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
#include "Vrv32i_rv32i_top_ram.h"
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
                if(i < 0x2000){
                    dut->rv32i_top->rom0->inner_rom[i/4] = value;
                }else{
                    dut->rv32i_top->ram0->inner_ram[i+0] = (uint8_t)(value & 0xff);
                    dut->rv32i_top->ram0->inner_ram[i+1] = (uint8_t)((value & 0xff00) >> 8);
                    dut->rv32i_top->ram0->inner_ram[i+2] = (uint8_t)((value & 0xff0000) >> 16);
                    dut->rv32i_top->ram0->inner_ram[i+3] = (uint8_t)((value & 0xff000000) >> 24);
                }
            }
            i += 4;
        }
        // for(int j = 0; j < i/4; j++){
        //     std::cout << std::setfill('0') << std::setw(8) << std::hex << dut->rv32i_top->rom0->inner_rom[j] << std::endl;
        // }
        // for(int j = 0; j < i/4; j++){
        //     std::cout << std::setfill('0') << std::setw(8) << std::hex << dut->rv32i_top->ram0->inner_ram[j] << std::endl;
        // }

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
        int cnt = 0;
        dut->clk = 0;
        dut->reset_n = 0;
        dut->eval();
        dut->clk = 1;
        dut->eval();
        dut->clk = 0;
        dut->eval();
        tfp->dump(cnt++);
        while (dut->rv32i_top->pc != 0x80000044) {
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
TEST_F(Rv32iTopTest, rv32ui_p_addi) {
    run_test("rv32ui-p-addi");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_and) {
    run_test("rv32ui-p-and");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_andi) {
    run_test("rv32ui-p-andi");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_auipc) {
    run_test("rv32ui-p-auipc");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_beq) {
    run_test("rv32ui-p-beq");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_bge) {
    run_test("rv32ui-p-bge");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_bgeu) {
    run_test("rv32ui-p-bgeu");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_blt) {
    run_test("rv32ui-p-blt");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_bltu) {
    run_test("rv32ui-p-bltu");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_bne) {
    run_test("rv32ui-p-bne");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
// TEST_F(Rv32iTopTest, rv32ui_p_fence_i) {
//     run_test("rv32ui-p-fence_i");
//     ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
// }
TEST_F(Rv32iTopTest, rv32ui_p_jal) {
    run_test("rv32ui-p-jal");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_jalr) {
    run_test("rv32ui-p-jalr");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_lb) {
    run_test("rv32ui-p-lb");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_lbu) {
    run_test("rv32ui-p-lbu");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_lh) {
    run_test("rv32ui-p-lh");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_lhu) {
    run_test("rv32ui-p-lhu");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_lui) {
    run_test("rv32ui-p-lui");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_lw) {
    run_test("rv32ui-p-lw");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_ma_data) {
    run_test("rv32ui-p-ma_data");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_or) {
    run_test("rv32ui-p-or");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_ori) {
    run_test("rv32ui-p-ori");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_sb) {
    run_test("rv32ui-p-sb");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_sh) {
    run_test("rv32ui-p-sh");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_simple) {
    run_test("rv32ui-p-simple");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_sll) {
    run_test("rv32ui-p-sll");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_slli) {
    run_test("rv32ui-p-slli");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_slt) {
    run_test("rv32ui-p-slt");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_slti) {
    run_test("rv32ui-p-slti");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_sltiu) {
    run_test("rv32ui-p-sltiu");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_sltu) {
    run_test("rv32ui-p-sltu");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_sra) {
    run_test("rv32ui-p-sra");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_srai) {
    run_test("rv32ui-p-srai");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_srl) {
    run_test("rv32ui-p-srl");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_srli) {
    run_test("rv32ui-p-srli");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_sub) {
    run_test("rv32ui-p-sub");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_sw) {
    run_test("rv32ui-p-sw");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

TEST_F(Rv32iTopTest, rv32ui_p_xor) {
    run_test("rv32ui-p-xor");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}
TEST_F(Rv32iTopTest, rv32ui_p_xori) {
    run_test("rv32ui-p-xori");
    ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
}

}  // namespace

