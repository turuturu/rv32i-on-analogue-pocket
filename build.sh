#!/bin/sh
cmake -S . -B _build -G Ninja
ninja -C _build
