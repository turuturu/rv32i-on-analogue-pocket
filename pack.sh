#!/bin/sh
BUILD_DIR=src/output_files
DIST_DIR=dist/Cores/turuturu.RV32I
echo ./bin/reverse_bits.exe $BUILD_DIR/ap_core.rbf $DIST_DIR/bitstream.rbf_r
./bin/reverse_bits.exe $BUILD_DIR/ap_core.rbf $DIST_DIR/bitstream.rbf_r
