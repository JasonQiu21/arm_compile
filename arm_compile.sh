#!/bin/bash

show_help() {
    echo "assemble, link, execute, and debug ARM assembly"
    echo "author:  Ryan Monaghan, Jason Qiu"
    echo "version: 1.0 - 10/4/2024"
    echo
    echo "Usage: asmExec [-h|-e|-d|-l|-g|-p <number>] -f <targetfile>"
    echo "e    execute after linking"
    echo "d    debug the program with gdb"
    echo "p    port number for debugging (default: 4321)"
    echo "l    link C library when assembling"
    echo "g    assemble with debug information"
    echo "o    output executable name"
    echo "f    specify file to run"
}

# No options
if [ $# -eq 0 ]
then
    show_help
    exit
fi

# Handle options
gdb=""
lc=""
execute=0
inputfile=""
targetfile=""
port_num="4321"
while getopts ":gledp:o:f:" option; do
    case $option in
        l)
            lc="-lc";;
        g)
            gdb="-g";;
        d)
            execute=2;;
        e)
            execute=1;;
        f)
            inputfile="$OPTARG";;
        p) 
            port_num="$OPTARG";;
        o)
            targetfile="$OPTARG"
            if [ -z $targetfile ] || [ "$targetfile" == "-f" ] # If targetfile is empty (check if equal to -f becasue if -f is called after it then we get this)
            then
                echo "you must specify an output file. type ./asmExec -h for help."
                exit
            fi;;
        ?)
            show_help
            exit;;
    esac
done


if [ -z $inputfile ] # If inputfile is empty
then
    echo "no input file specified"
    exit
fi

if [ -z $targetfile ]
then
    targetfile=${inputfile%.*}
fi
echo "assembling and linking '$inputfile'..."
aarch64-linux-gnu-as $gdb $inputfile -o $targetfile.o
aarch64-linux-gnu-ld $targetfile.o -o $targetfile $lc
echo "done."

if [ $execute -eq 1 ]
then
    echo "executing..."
    if [ -n $lc ]
    then
        qemu-aarch64 -L /usr/aarch64-linux-gnu/ $targetfile
    else
        qemu-aarch64 $targetfile
    fi
    echo "done."
elif [ $execute -eq 2 ]
then
    echo "executing in debug mode..."
    if [ -n $lc ] 
    then
        qemu-aarch64 -L /usr/aarch64-linux-gnu/ -g $port_num $targetfile &
    else
        qemu-aarch64 -g $port_num $targetfile &
    fi 
    echo "starting debug on port $port_num..." &
    gdb-multiarch --nh -q $targetfile \
        -ex "set disassemble-next-line on" \
        -ex "target remote :$port_num" \
        -ex "set solib-search-path/usr/aarch64-linux-gnu-lib/" \
        -ex "layout regs"
    pkill -9 qemu
    echo "done."
    exit
fi
