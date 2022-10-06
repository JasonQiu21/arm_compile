#!/usr/bin/env bash

usage(){
    echo "Invalid usage. Type ./arm_compile.sh -h for help."
}

help(){
    echo "Script to assemble, link, execute, and debug ARM assembly"
    echo
    echo "Usage: ./arm_compile.sh [-h|-e|-l|-g|-o <file>] -f <targetfile>"
    echo "h    Print this help"
    echo "e    Execute after linking"
    echo "l    Link C library when compiling"
    echo "g    Debug with gdb (You will need to open another terminal to run gdb)"
    echo "o    Specify output file (default: same as target)"
    echo "f    Specify target file"
    echo
    echo "Script will leave assembled .o files as well as ARM binary, all with the same name as targetfile (NOT a.out) unless -o specified."
    echo
}


# No options
if [ $# -eq 0 ]
then 
    usage
    exit
fi

# Handle options
gdb=""
lc=""
execute=0
inputfile=""
targetfile=""
while getopts ":hgleo:f:" option; do
    case $option in
        h)
            help
            exit;;
        e)
            execute=1;;
        l)
            lc=" -lc";;
        g)
            gdb="-g ";;
        o)
            targetfile="$OPTARG"
            if [ -z $targetfile ]
            then
                echo "You must specify an output file. Type ./arm_compile.sh -h for help."
                exit
            fi;;
        f)
            inputfile="$OPTARG";;
        ?)
            usage
            exit;;
    esac
done

if [ -z $inputfile ] # If inputfile is empty
then
    echo "You must specify an input file. Type ./arm_compile.sh -h for help."
    exit
fi

if [ -z $targetfile ]
then
    targetfile=${inputfile%.*}
fi
echo "Compiling $inputfile..."
aarch64-linux-gnu-as $gdb$inputfile -o $targetfile.o
aarch64-linux-gnu-ld $targetfile.o -o $targetfile$lc
echo "Done compiling."

if [ $execute -eq 1 ]
then
    echo "Executing ..."
    if [ -n $lc ]
        then
            qemu-aarch64 -L /usr/aarch64-linux-gnu/ $targetfile
        else
            qemu-aarch64 $targetfile
    fi
    echo "Done executing."
fi


if [ -z $gdb]
then
    exit
fi
qemu-aarch64 -L /usr/aarch64-linux-gnu/ -g 4321 $targetfile &
echo "Starting debug on port 4321..." &
gdb-multiarch --nh -q $targetfile \
-ex 'set disassemble-next-line on' \
-ex 'target remote :4321' \
-ex 'set solib-search-path/usr/aarch64-linux-gnu-lib/' \
-ex 'layout reg'
