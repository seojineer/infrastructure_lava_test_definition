#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/cmu-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_verify_cmu_functionality() {
    info_msg "Running Verifying CMU Functionality Test..."
    dmesg | grep -i pll_cpucl | tee "$LOGFILE"

    if [ -n "$(sed -n '/PLL_CPUCL/p' $LOGFILE)" ]; then
        report_pass "verify-cmu-functionality-test"
    else
        report_fail "verify-cmu-functionality-test"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_verify_cmu_functionality
