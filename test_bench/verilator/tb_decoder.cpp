#include <cassert>
#include <iostream>
#include <verilated.h>
#include "Vdecoder.h"
#include "Vdecoder___024unit.h"

int time_counter = 0;

int main(int argc, char** argv) {

  Verilated::commandArgs(argc, argv);

  // Instantiate DUT
  Vdecoder *dut = new Vdecoder();
  // LUI
  dut->instr = 0b0000'0000'0000'0000'0000'0000'0011'0111;
  dut->eval();
  assert(dut->alu_op == Vdecoder___024unit::alu_op_e::ALU_LUI);
  // error test
  assert(dut->alu_op == 99);

  dut->final();
}