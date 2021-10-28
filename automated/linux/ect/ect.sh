#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/ect-stdout.txt"
ECT_FILE="$(pwd)/file/ect_data.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_verify_ECT_data() {
    info_msg "Running Verifying parsed ECT data Test..."
    cat /sys/kernel/debug/ect/all_dump | grep NAME | tee "$LOGFILE"
    diff $LOGFILE $ECT_FILE
    check_return "verify-parsed-ect-data"
}

# Test run.
create_out_dir "${OUTPUT}"
test_verify_ECT_data

