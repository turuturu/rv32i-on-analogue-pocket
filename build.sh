#!/bin/sh
cmake -S . -B _build -G Ninja
cmake --build _build/
