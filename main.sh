#!/bin/sh
set -e
nasm -f bin bios.asm -o demo/bios.raw
python3 -m http.server -d demo
