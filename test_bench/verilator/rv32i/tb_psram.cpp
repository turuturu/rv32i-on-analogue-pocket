#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_psram.h"
#include "Vrv32i_psram_psram.h"
#include "Vrv32i_psram_rv32i.h"

#include <climits>
#include <random>

class PsramTest : public ::testing::Test {
   protected:
    Vrv32i_psram *dut;

    void SetUp() override { dut = new Vrv32i_psram(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
    void next(){
        dut->clk = !dut->clk;
        dut->eval();
    }
    void period(int count){
        for(int i = 0; i < count; i++){
            next();
            next();
        }
    }
};

namespace {

TEST_F(PsramTest, WRITE_READ) {
    // state: NONE
    dut->clk = 0;
    dut->eval();
    printf("state: %d\n", dut->psram->state); // STATE_NONE
    // init
    dut->bank_sel = 0;
    dut->addr = 0x2f0B00;
    dut->write_en = 1;
    dut->data_in = 0xccbb;
    dut->write_high_byte = 0;
    dut->write_low_byte = 0;
    dut->read_en = 0;
    dut->cram_dq = 0;
    dut->cram_wait = 0;
    period(1);
    printf("state: %d\n", dut->psram->state); // STATE_WRITE_ADV_END
    ASSERT_EQ(dut->cram_ce0_n, 0);
    ASSERT_EQ(dut->cram_ce1_n, 1);
    ASSERT_EQ(dut->psram->data_out_en, 1);
    ASSERT_EQ(dut->cram_we_n, 0);
    ASSERT_EQ(dut->cram_adv_n, 0);
    ASSERT_EQ(dut->cram_ub_n, 1);
    ASSERT_EQ(dut->cram_lb_n, 1);
    ASSERT_EQ(dut->busy, 1);

    ASSERT_EQ(dut->cram_a, 0x2f);
    ASSERT_EQ(dut->cram_dq, 0x0b00);
    ASSERT_EQ(dut->psram->latched_data_in, 0xccbb);

    dut->bank_sel = 1;
    dut->addr = 0;
    dut->write_en = 0;
    dut->data_in = 0xffff;

    period(1);
    printf("state: %d\n", dut->psram->state); // STATE_WRITE_ADDR_LATCH_END
    ASSERT_EQ(dut->cram_adv_n, 1);
    period(2);
    printf("state: %d\n", dut->psram->state); // STATE_WRITE_DATA_START
    ASSERT_EQ(dut->psram->data_out_en, 0);
    period(7);
    printf("state: %d\n", dut->psram->state); // STATE_WRITE_DATA_END
    ASSERT_EQ(dut->psram->data_out_en, 1);
    ASSERT_EQ(dut->psram->cram_data, 0xccbb);
    period(1);
    printf("state: %d\n", dut->psram->state); // STATE_NONE
    ASSERT_EQ(dut->psram->data_out_en, 0);
    ASSERT_EQ(dut->cram_ce0_n, 1);
    ASSERT_EQ(dut->cram_ce1_n, 1);
    ASSERT_EQ(dut->psram->data_out_en, 0);
    ASSERT_EQ(dut->cram_we_n, 1);
    ASSERT_EQ(dut->cram_ub_n, 1);
    ASSERT_EQ(dut->cram_lb_n, 1);
    ASSERT_EQ(dut->busy, 0);
    period(1);
    printf("state: %d\n", dut->psram->state); // STATE_NONE
    // read test 
    dut->bank_sel = 0;
    dut->addr = 0x2f0B00;
    dut->read_en = 1;
    period(1);
    printf("state: %d\n", dut->psram->state); // STATE_READ_ADV_END
    ASSERT_EQ(dut->cram_ce0_n, 0);
    ASSERT_EQ(dut->cram_ce1_n, 1);
    ASSERT_EQ(dut->psram->data_out_en, 1);
    ASSERT_EQ(dut->cram_adv_n, 0);
    ASSERT_EQ(dut->cram_ub_n, 0);
    ASSERT_EQ(dut->cram_lb_n, 0);
    ASSERT_EQ(dut->busy, 1);

    ASSERT_EQ(dut->cram_a, 0x2f);
    ASSERT_EQ(dut->psram->cram_data, 0x0b00);
    ASSERT_EQ(dut->psram->cram_dq, 0x0b00);
    dut->bank_sel = 1;
    dut->addr = 0;
    dut->read_en = 0;

    period(1);
    printf("state: %d\n", dut->psram->state); // STATE_READ_ADDR_LATCH_END
    ASSERT_EQ(dut->cram_adv_n, 1);
    period(1);
    printf("state: %d\n", dut->psram->state); // STATE_READ_DATA_ENABLE
    ASSERT_EQ(dut->psram->data_out_en, 0);
    period(1);
    printf("state: %d\n", dut->psram->state); // STATE_READ_DATA_RECEIVED
    ASSERT_EQ(dut->psram->cram_oe_n, 0);
    period(8);
    printf("state: %d\n", dut->psram->state); // STATE_NONE
    ASSERT_EQ(dut->psram->read_avail, 1);
    ASSERT_EQ(dut->cram_ce0_n, 1);
    ASSERT_EQ(dut->cram_ce1_n, 1);
    ASSERT_EQ(dut->cram_oe_n, 1);
    ASSERT_EQ(dut->cram_ub_n, 1);
    ASSERT_EQ(dut->cram_lb_n, 1);
    ASSERT_EQ(dut->busy, 0);
}

}  // namespace

