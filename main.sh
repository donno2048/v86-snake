#!/bin/sh

set -e
nasm -f bin main.asm -o demo/main.raw
python3 -m http.server -d demo
