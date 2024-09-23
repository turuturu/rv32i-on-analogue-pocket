#include <gtest/gtest.h>
#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <climits>
#include <random>
#include <iostream>
#include <fstream>
#include <string>

#include "Vrv32i_rv32i_top_wrapper.h"
#include "Vrv32i_rv32i_top_wrapper_registers.h"
#include "Vrv32i_rv32i_top_wrapper_rom.h"
#include "Vrv32i_rv32i_top_wrapper_ram.h"
#include "Vrv32i_rv32i_top_wrapper_rv32i_top.h"
#include "Vrv32i_rv32i_top_wrapper_rv32i_top_wrapper.h"
#include <memory>
#include <cstdio>
#include <iomanip> // std::setfill, std::setwを使用するために必要

std::string BASE_PATH = "_build/riscv-tests-bin/";
class Rv32iTopWrapperTest : public ::testing::Test {
   protected:
    Vrv32i_rv32i_top_wrapper *dut;

    void SetUp() override { dut = new Vrv32i_rv32i_top_wrapper(); }

    void TearDown() override {
        // dut->final();
        // delete dut;
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
                    dut->rv32i_top_wrapper->rom0->inner_rom[i/4] = value;
                }else{
                    dut->rv32i_top_wrapper->rv32i_top0->ram0->inner_ram0[i/4] = (uint8_t)(value & 0xff);
                    dut->rv32i_top_wrapper->rv32i_top0->ram0->inner_ram1[i/4] = (uint8_t)((value & 0xff00) >> 8);
                    dut->rv32i_top_wrapper->rv32i_top0->ram0->inner_ram2[i/4] = (uint8_t)((value & 0xff0000) >> 16);
                    dut->rv32i_top_wrapper->rv32i_top0->ram0->inner_ram3[i/4] = (uint8_t)((value & 0xff000000) >> 24);
                }
            }
            i += 4;
        }
        // for(int j = 0; j < i/4; j++){
        //     std::cout << std::setfill('0') << std::setw(8) << std::hex << dut->rv32i_top_wrapper->rom0->inner_rom[j] << std::endl;
        // }
        // for(int j = 0; j < i/4; j++){
        //     std::cout << std::setfill('0') << std::setw(8) << std::hex << dut->rv32i_top_wrapper->rv32i_top0->ram0->inner_ram0[j] << std::endl;
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
        dut->clk = 1;
        dut->eval();
        tfp->dump(cnt++);
        dut->clk = 0;
        dut->eval();
        tfp->dump(cnt++);
        dut->clk = 1;
        dut->eval();
        tfp->dump(cnt++);
        dut->clk = 0;
        dut->reset_n = 0;
        dut->eval();
        tfp->dump(cnt++);
        dut->reset_n = 1;
        while (dut->rv32i_top_wrapper->rv32i_top0->pc != 0x80000044 && cnt < 2000) {
            dut->clk = 1;
            dut->eval();
            tfp->dump(cnt++);
            dut->clk = 0;
            dut->eval();
            tfp->dump(cnt++);
        }
        dut->final();
        tfp->close();
        // ASSERT_EQ(dut->rv32i_top_wrapper->rv32i_top0->register3, (uint32_t)1);
        ASSERT_EQ(dut->rv32i_top_wrapper->rv32i_top0->registers0->regs[3], (uint32_t)1);
    }

};

namespace {

TEST_F(Rv32iTopWrapperTest, rv32ui_p_add) {
    run_test("rv32ui-p-add");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_addi) {
    run_test("rv32ui-p-addi");
    // ASSERT_EQ(dut->rv32i_top_wrapper->rv32i_top0->registers0->regs[3], 1);
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_and) {
    run_test("rv32ui-p-and");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_andi) {
    run_test("rv32ui-p-andi");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_auipc) {
    run_test("rv32ui-p-auipc");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_beq) {
    run_test("rv32ui-p-beq");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_bge) {
    run_test("rv32ui-p-bge");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_bgeu) {
    run_test("rv32ui-p-bgeu");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_blt) {
    run_test("rv32ui-p-blt");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_bltu) {
    run_test("rv32ui-p-bltu");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_bne) {
    run_test("rv32ui-p-bne");
}
// TEST_F(Rv32iTopWrapperTest, rv32ui_p_fence_i) {
//     run_test("rv32ui-p-fence_i");
//     ASSERT_EQ(dut->rv32i_top->registers0->regs[3], 1);
// }
TEST_F(Rv32iTopWrapperTest, rv32ui_p_jal) {
    run_test("rv32ui-p-jal");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_jalr) {
    run_test("rv32ui-p-jalr");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_lb) {
    run_test("rv32ui-p-lb");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_lbu) {
    run_test("rv32ui-p-lbu");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_lh) {
    run_test("rv32ui-p-lh");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_lhu) {
    run_test("rv32ui-p-lhu");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_lui) {
    run_test("rv32ui-p-lui");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_lw) {
    run_test("rv32ui-p-lw");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_ma_data) {
    run_test("rv32ui-p-ma_data");
}

TEST_F(Rv32iTopWrapperTest, rv32ui_p_or) {
    run_test("rv32ui-p-or");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_ori) {
    run_test("rv32ui-p-ori");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_sb) {
    run_test("rv32ui-p-sb");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_sh) {
    run_test("rv32ui-p-sh");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_simple) {
    run_test("rv32ui-p-simple");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_sll) {
    run_test("rv32ui-p-sll");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_slli) {
    run_test("rv32ui-p-slli");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_slt) {
    run_test("rv32ui-p-slt");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_slti) {
    run_test("rv32ui-p-slti");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_sltiu) {
    run_test("rv32ui-p-sltiu");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_sltu) {
    run_test("rv32ui-p-sltu");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_sra) {
    run_test("rv32ui-p-sra");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_srai) {
    run_test("rv32ui-p-srai");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_srl) {
    run_test("rv32ui-p-srl");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_srli) {
    run_test("rv32ui-p-srli");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_sub) {
    run_test("rv32ui-p-sub");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_sw) {
    run_test("rv32ui-p-sw");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_xor) {
    run_test("rv32ui-p-xor");
}
TEST_F(Rv32iTopWrapperTest, rv32ui_p_xori) {
    run_test("rv32ui-p-xori");
}

}  // namespace

