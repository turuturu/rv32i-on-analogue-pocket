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
add_executable(test_all
  test_bench/verilator/tb_decoder.cpp
  test_bench/verilator/main.cpp
)
target_link_libraries(
  test_all
  PRIVATE
  GTest::gtest_main
)

set_target_properties(test_all PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON
  COMPILE_FLAGS "-Wall -g -fsanitize=address"
  LINK_FLAGS "-fsanitize=address"
)

include(GoogleTest)
gtest_discover_tests(test_all)

####################
# Verilate
####################

verilate(test_all
  INCLUDE_DIRS "src/rtl"
  SOURCES
  src/rtl/rv32i/decoder.sv
  PREFIX Valu
)

####################
# pfDevTool
####################
add_custom_target(pfbuild COMMAND "pf" "make" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
