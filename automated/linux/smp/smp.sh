#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE_cores="${OUTPUT}/smp-cores-stdout.txt"
LOGFILE_func="${OUTPUT}/smp-functionality-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_check_cores_enabled() {
    info_msg "Running Checking Cores are Enabled Test..."
    cat /sys/devices/system/cpu/online | tee "$LOGFILE_cores"

    if [ -n "$(sed -n '/0-7/p' $LOGFILE_cores)" ]; then
        report_pass "verify-cores-enabled-test"
    else
        report_fail "verify-cores-enabled-test"
    fi
}

test_smp_functionality() {
    info_msg "Running Checking SMP functionality Test..."

    dmesg | grep CPU | tee "$LOGFILE_func"

    pass_flag=true
    if [ -n "$(sed -n '/smp: Bringing up secondary CPUs/p' $LOGFILE_func)" ]; then
        for ((index=1; index <8; index++)); do
	    if [ ! -n "$(sed -n "/Detected PIPT I-cache on CPU$index/p" "$LOGFILE_func")" ] || \
	       [ ! -n "$(sed -n "/CPU$index: Booted secondary processor/p" "$LOGFILE_func")" ]; then
	       pass_flag=false
	       warn_msg "CPU$index not shown in log."
	    fi
	done
    else
        pass_flag=false
    fi
    if [ "$pass_flag" == "true" ]; then
        report_pass "check-smp-functionality-test"
    else
        report_fail "check-smp-functionality-test"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_check_cores_enabled
test_smp_functionality
