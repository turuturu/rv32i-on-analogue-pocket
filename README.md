## Prerequisites

- [cmake](https://cmake.org/)
- [pfDevTool](https://codeberg.org/DidierMalenfant/pfDevTools)
- [Verilator](https://www.veripool.org/verilator/)
- [Icarus Verilog](https://github.com/steveicarus/iverilog)
- [Google Test](https://google.github.io/googletest/)

## run testbench

```
cmake -S . -B _build -G Ninja;
ninja -C _build;
./_build/test_all;
```

## build

```
pf build;
```
