# V86-Snake

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

## Size

The game is `111` bytes including all the code used to initialize the hardware (ignoring the last 4 bytes because we need them just because of a V86 bug as detailed in the comments, and filler null bytes).

Here it is as a QR Code (made with `qrencode -r <(sed 's/\x00*....$//' demo/bios.raw) -8 -o qr.png`):

![](./qr.png)


The [`libv86`](./demo/libv86.js) and [`v86`](./demo/v86.wasm) are genrated like so:

```sh
git clone --depth 1 https://github.com/donno2048/v86
cd v86
make all
cp build/libv86.js build/v86.wasm ../demo
cd ..
rm -rf v86
```


