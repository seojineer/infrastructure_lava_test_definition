#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
MO_LOGFILE="${OUTPUT}/bts-mo-stdout.txt"
QOS_LOGFILE="${OUTPUT}/bts-qos-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_verify_bts_MO_value() {
    info_msg "Running Verifying bts MO values Test..."

    cat /sys/kernel/debug/bts/mo | tee "$MO_LOGFILE"
    check_return "verify-bts-MO-value-test"
}

test_verify_bts_QOS_value() {
    info_msg "Running Verifying bts QOS values Test..."

    cat /sys/kernel/debug/bts/qos | tee "$QOS_LOGFILE"
    check_return "verify-bts-QOS-value-test"
}

# Test run.
create_out_dir "${OUTPUT}"
test_verify_bts_MO_value
test_verify_bts_QOS_value
