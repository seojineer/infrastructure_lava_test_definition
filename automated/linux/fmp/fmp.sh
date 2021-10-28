#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
TESTS="ls -all /sys/devices/platform | grep fmp, dmesg | grep fmp"
echo $TEMP

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

run() {
    # shellcheck disable=SC2039
    local test="$1"
    test_case_id="$(echo "${test}" | awk '{print $1}')"
    echo
    info_msg "Running ${test_case_id} test..."
    eval "${test}"
    check_return "${test_case_id}"
}

# Test run.
create_out_dir "${OUTPUT}"
for test in "ls -all /sys/devices/platform | grep fmp" "dmesg | grep fmp"; do
    test_cmd="$test"
    run "${test_cmd}"
    test="$(echo "$test" | sed -r "s#${test_cmd},? *##")"
done
