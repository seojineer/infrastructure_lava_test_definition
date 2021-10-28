#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
LOGFILE="${OUTPUT}/rpmb-blocking-stdout.txt"
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

test_rpmb_key_blocking() {
    info_msg "Running Verify RPMB key blocking Test..."
    cat /sys/kernel/debug/dram_bootlog/bootlog | grep RPMB | tee "$LOGFILE"
    local exit_code="$?"
    if [ -n "$(sed -n '/key blocked successfully/p' $LOGFILE)" ]; then
        report_pass "verify-rpmb-key-blocking-test"
    else
        report_fail "verify-rpmb-key-blocking-test"
    fi
    return "${exit_code}"
}

# Test run.
create_out_dir "${OUTPUT}"

test_rpmb_key_blocking
