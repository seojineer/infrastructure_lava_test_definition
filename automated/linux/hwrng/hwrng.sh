#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_hwrng() {
    info_msg "Running Kernel HW Random Generation Test..."
    dd if=/dev/hwrng of=random_1.bin bs=1 count=20480
    check_return "hw-random-generation-test"
}

# Test run.
create_out_dir "${OUTPUT}"

test_hwrng
