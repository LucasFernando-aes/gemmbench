#!/bin/bash

# Default values from Makefile
QEMU_DEFAULT="/home/user/eldorado-teiu/compilers/riscv/bin/qemu-riscv64"
QEMU_FLAGS_DEFAULT="-cpu rv64,g=true,c=true,v=true,vext_spec=v1.0,vlen=256,elen=64"

# Allow user to override defaults via environment variables or command-line arguments
QEMU="${QEMU_OVERRIDE:-$QEMU_DEFAULT}"
QEMU_FLAGS="${QEMU_FLAGS_OVERRIDE:-$QEMU_FLAGS_DEFAULT}"

# Parse arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <exec> <csv_file> [qemu] [qemu_flags]"
    echo "      <exec>: path to the GEMMVBench executable"
    echo "      <csv_file>: path to the CSV file containing GEMM configurations."
    echo "      [qemu]: optional, path to QEMU binary (default: $QEMU_DEFAULT)"
    echo "      [qemu_flags]: optional, QEMU CPU flags (default: $QEMU_FLAGS_DEFAULT)"
    exit 1
fi

# Override QEMU and QEMU_FLAGS if provided as command-line arguments
EXEC=$1
CSV_FILE=$2
if [ ! -z "$3" ]; then QEMU=$3; fi
if [ ! -z "$4" ]; then QEMU_FLAGS=$4; fi

# Read CSV header
IFS=, read -r -a HEADER < "$CSV_FILE"

# Initialize counters
success_count=0
failure_count=0

# Process CSV entries
while IFS=, read -r M N K ALPHA BETA; do #"${HEADER[@]}"; do

    echo "$M $N $K $ALPHA $BETA"
    if $QEMU $QEMU_FLAGS $EXEC $M $N $K $ALPHA $BETA; then
        echo -e "\tsuccess"
        success_count=$((success_count + 1))
    else
        echo "$M $N $K $ALPHA $BETA"
        echo -e "\tFailure"
        failure_count=$((failure_count + 1))
    fi
done < <(tail -n +2 "$CSV_FILE")

# Print summary
echo "Total Success: $success_count"
echo "Total Failure: $failure_count"
