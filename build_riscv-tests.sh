#!/bin/bash

pushd riscv-tests
./configure --prefix=$(pwd)/target --with-xlen=32
make isa
make install
cd target/share/riscv-tests/isa
for f in $(ls rv* | grep -v -E ".dump|.bin"); do
  riscv64-unknown-elf-objcopy -O binary $f $f.bin
done
popd
