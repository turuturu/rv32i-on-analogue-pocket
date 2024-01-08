cmake_minimum_required(VERSION 3.14)
project(verilog_unittest_sample)

# https://cmake.org/cmake/help/latest/policy/CMP0135.html
cmake_policy(SET CMP0135 NEW)

# find_package() uses upper-case <PACKAGENAME>_ROOT variables in conjunction with CMP0074.
# https://cmake.org/cmake/help/latest/policy/CMP0144.html
if(POLICY CMP0144)
    cmake_policy(SET CMP0144 NEW)
endif()
####################
# Verilator
####################

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

####################
# GoogleTest
####################

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_COLOR_DIAGNOSTICS ON)
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)

# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

####################
# Test
####################

enable_testing()

# set_target_properties(test_all PROPERTIES
#   CXX_STANDARD 17
#   CXX_STANDARD_REQUIRED ON
#   COMPILE_FLAGS "-Wall -g -fsanitize=address"
#   LINK_FLAGS "-fsanitize=address"
#)
# add_executable(test_all
#   test_bench/verilator/tb_rv32i_top.cpp
#   test_bench/verilator/tb_decoder.cpp
#   test_bench/verilator/main.cpp
# )
# target_link_libraries(
#   test_all
#   PRIVATE
#   GTest::gtest_main
# )

add_executable(test_rv32i_decoder
  test_bench/verilator/rv32i/tb_decoder.cpp
  test_bench/verilator/main.cpp
)
target_link_libraries(
  test_rv32i_decoder
  PRIVATE
  GTest::gtest_main
)

add_executable(test_rv32i_alu
  test_bench/verilator/rv32i/tb_alu.cpp
  test_bench/verilator/main.cpp
)
target_link_libraries(
  test_rv32i_alu
  PRIVATE
  GTest::gtest_main
)
add_executable(test_rv32i_ram
  test_bench/verilator/rv32i/tb_ram.cpp
  test_bench/verilator/main.cpp
)
target_link_libraries(
  test_rv32i_ram
  PRIVATE
  GTest::gtest_main
)
add_executable(test_rv32i_registers
  test_bench/verilator/rv32i/tb_registers.cpp
  test_bench/verilator/main.cpp
)
target_link_libraries(
  test_rv32i_registers
  PRIVATE
  GTest::gtest_main
)

add_executable(test_rv32i_rom
  test_bench/verilator/rv32i/tb_rom.cpp
  test_bench/verilator/main.cpp
)
target_link_libraries(
  test_rv32i_rom
  PRIVATE
  GTest::gtest_main
)

add_executable(test_rv32i_top
  test_bench/verilator/rv32i/tb_rv32i_top.cpp
  test_bench/verilator/main.cpp
)
target_link_libraries(
  test_rv32i_top
  PRIVATE
  GTest::gtest_main
)

include(GoogleTest)
gtest_discover_tests(test_rv32i_decoder)
gtest_discover_tests(test_rv32i_alu)
gtest_discover_tests(test_rv32i_ram)
gtest_discover_tests(test_rv32i_registers)
gtest_discover_tests(test_rv32i_rom)
gtest_discover_tests(test_rv32i_top)

####################
# Verilate
####################

verilate(test_rv32i_decoder
  INCLUDE_DIRS "src/rtl"
  SOURCES
    src/rtl/rv32i/decoder.sv
  PREFIX Valu
)
verilate(test_rv32i_alu
  INCLUDE_DIRS "src/rtl"
  SOURCES
    src/rtl/rv32i/alu.sv
  PREFIX Valu
)
verilate(test_rv32i_ram
  INCLUDE_DIRS "src/rtl"
  SOURCES
    src/rtl/rv32i/ram.sv
  PREFIX Valu
)
verilate(test_rv32i_registers
  INCLUDE_DIRS "src/rtl"
  SOURCES
    src/rtl/rv32i/registers.sv
  PREFIX Valu
)
verilate(test_rv32i_rom
  INCLUDE_DIRS "src/rtl"
  SOURCES
    src/rtl/rv32i/rom.sv
  PREFIX Valu
)
verilate(test_rv32i_top
  INCLUDE_DIRS "src/rtl"
  SOURCES
    src/rtl/rv32i/rv32i_top.sv
  PREFIX Valu
)


####################
# pfDevTool
####################
add_custom_target(pfbuild COMMAND "pf" "make" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
