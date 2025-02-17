# V86-Snake

## THIS IS A WORK IN PROGRESS

And currently doesn't work really well.

This project was inspired by another project of mine [a BIOS only snake game](https://github.com/donno2048/snake-bios) which I wasn't able to show a demo of because I couldn't find any online tool to imitate QEMU.

This is a BIOS only snake game that works in [v86](https://github.com/copy/v86) so I can easily host it online.

## Running

### Online demo

You can try the game in the [online demo](https://donno2048.github.io/v86-snake/).
Use the numpad arrow keys on PC or swipe on mobile.

### Self-hosting

To run the game locally you'll have to install the dependencies and build the game from source:

#### Installation

I'm using `nasm` and `python3` which can be installed with `apt install nasm python3 -y`.

#### Building

To test it just run [`main.sh`](/main.sh) and open http://localhost:8000.


The [`libv86`](./demo/libv86.js) and [`v86`](./demo/v86.wasm) are genrated like so:

```sh
git clone --depth 1 https://github.com/donno2048/v86
cd v86
make all
cp build/libv86.js build/v86.wasm ../demo
cd ..
rm -rf v86
```

## TODOs:

- Fix wrapping to remove redundant `jmp $$`


