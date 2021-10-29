#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
TESTS="uart arch_timer mct"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "t:h" o; do
  case "$o" in
    t) TESTS="${OPTARG}" ;;
    h|*) usage ;;
  esac
done

test_interrupt_controller() {
    local dev=$1
    irq=`grep $dev /proc/interrupts  | awk '{print $2}'`
    for ((cnt=0; cnt<5; cnt++)); do
        irq_inc=`grep $dev /proc/interrupts  | awk '{print $2}'`
        echo $irq_inc
    done

    if [ "$irq" == "" ]; then
        report_fail "verifying-interrupt-counter-increasing-test-$dev"
    else
        if [ $irq_inc -gt $irq ]; then
            report_pass "verifying-interrupt-counter-increasing-test-$dev"
        else
	    warn_msg "interrupt counter not increased"
            report_fail "verifying-interrupt-counter-increasing-test-$dev"
        fi
    fi
}

# Test run.
create_out_dir "${OUTPUT}"

info_msg "Running Verifying interrupt counter increasing Test..."
for tc in $TESTS; do
    echo "tc $tc"
    test_interrupt_controller $tc
done

