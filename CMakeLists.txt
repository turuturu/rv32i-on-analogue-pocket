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
set(CMAKE_COMPILE_FLAGS "-Wall -g -fsanitize=address")
set(CMAKE_LINK_FLAGS "-fsanitize=address")


include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)

# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

####################
# Google Test
####################
enable_testing()
# common settings
add_library(gtest_shared
  test_bench/verilator/main.cpp
)
target_link_libraries(
  gtest_shared
  PUBLIC
  GTest::gtest_main
)

####################
# riscv-tests
####################
set(RISCV_TESTS_BIN_DIR "${CMAKE_BINARY_DIR}/riscv-tests-bin")
file(GLOB RISCV_TESTS_BIN "riscv-tests/target/share/riscv-tests/isa/*.bin")
file(COPY ${RISCV_TESTS_BIN} DESTINATION ${RISCV_TESTS_BIN_DIR})
file(GLOB RISCV_TESTS_DUMP "riscv-tests/target/share/riscv-tests/isa/*.dump")
file(COPY ${RISCV_TESTS_DUMP} DESTINATION ${RISCV_TESTS_BIN_DIR})

####################
# Test
####################
# targets
set(targets decoder; alu; csr_registers; ram; registers; rom; rv32i_top_wrapper; reg_mask; psram;)

# test bench
foreach(target IN LISTS targets)
  add_executable(test_rv32i_${target}
    test_bench/verilator/rv32i/tb_${target}.cpp
  )
  target_link_libraries(test_rv32i_${target}
    PRIVATE gtest_shared
  )
endforeach()

# gtest
include(GoogleTest)
foreach(target IN LISTS targets)
  gtest_discover_tests(test_rv32i_${target})
endforeach()

####################
# Verilate
####################
list(APPEND VERILATOR_ARGS --trace)
list(APPEND VERILATOR_ARGS --trace-params)
list(APPEND VERILATOR_ARGS --trace-structs)
list(APPEND VERILATOR_ARGS --trace-underscore )
list(APPEND VERILATOR_ARGS --public-flat-rw  )

# --trace --trace-params --trace-structs --trace-underscore \

foreach(target IN LISTS targets)
  verilate("test_rv32i_${target}"
    INCLUDE_DIRS "src/rtl"
    SOURCES
      "src/rtl/rv32i/${target}.sv"
    PREFIX Vrv32i_${target}
    VERILATOR_TRACE ON
    VERILATOR_TRACE_VCD ON
    VERILATOR_TRACE_FST ON
    VERILATE_TRACE_STRUCTS ON
  )
endforeach()

####################
# pfDevTool
####################
add_custom_target(pfbuild COMMAND "pf" "make" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
