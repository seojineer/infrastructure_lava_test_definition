#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE_fmp1="${OUTPUT}/fmp1-stdout.txt"
LOGFILE_fmp2="${OUTPUT}/fmp2-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_fmp_driver_probe1() {
    info_msg "Running FMP driver Probe Test1..."

    ls -all /sys/devices/platform | grep fmp | tee $LOGFILE_fmp1

    if [ -n "$(sed -n '/fmp/p' $LOGFILE_fmp1)" ]; then
        report_pass "check-fmp-driver-probe-test1"
    else
        report_fail "check-fmp-driver-probe-test1"
    fi
}

test_fmp_driver_probe2() {
    info_msg "Running FMP driver Probe Test2..."

    dmesg | grep fmp | tee $LOGFILE_fmp2

    if [ -n "$(sed -n '/Exynos FMP driver is initialized/p' $LOGFILE_fmp2)" ]; then
        report_pass "check-fmp-driver-probe-test2"
    else
        report_fail "check-fmp-driver-probe-test2"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_fmp_driver_probe1
test_fmp_driver_probe2
