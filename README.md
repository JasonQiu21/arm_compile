# arm_compile

Script to assemble, link, execute, and debug ARM assembly

## Usage

```
assemble, link, execute, and debug ARM assembly
author:  Ryan Monaghan, Jason Qiu
version: 1.0 - 10/4/2024

Usage: ./arm_compile [-h|-e|-d|-l|-g|-p <number>] -f <targetfile>
e    execute after linking
d    debug the program with gdb
p    port number for debugging (default: 4321)
l    link C library when assembling
g    assemble with debug information
o    output executable name
f    specify file to run

```

Depends on package `aarch64-linux-gnu-binutils`, `aarch64-linux-gnu-gcc`, `qemu-user`. To use debug, install `gdb-multiarch`.
