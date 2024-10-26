#include <gtest/gtest.h>
#include <verilated.h>
#include "Vrv32i_rom_cache.h"

#include <climits>
#include <random>

class RomCacheTest : public ::testing::Test {
   protected:
    Vrv32i_rom_cache *dut;

    void SetUp() override { dut = new Vrv32i_rom_cache(); }

    void TearDown() override {
        dut->final();
        delete dut;
    }
};

namespace {

TEST_F(RomCacheTest, READ_WRITE) {
    uint32_t vals[] = {
        0x00000001,
        0x00000002,
        0x00000003,
        0x00000004,
    };
    int length = sizeof(vals);
    int i = 0;
} 

}  // namespace

