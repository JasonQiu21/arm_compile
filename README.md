# arm_compile

Script to assemble, link, execute, and debug ARM assembly

## Usage

```
"Script to assemble, link, execute, and debug ARM assembly"

"Usage: ./arm_compile.sh [-h|-e|-l|-g|-o <file>] -f <targetfile>"
"h    Print this help"
"e    Execute after linking"
"l    Link C library when compiling"
"g    Debug with gdb (You will need to open another terminal to run gdb)"
"o    Specify output file (default: same as target)"
"f    Specify target file"

"Script will leave assembled .o files as well as ARM binary, all with the same name as targetfile (NOT a.out) unless -o specified."
```

Depends on package `aarch64-linux-gnu-binutils`, `aarch64-linux-gnu-gcc`, `qemu-user`. To use debug, install `gdb-multiarch`.
