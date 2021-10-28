#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/pdma-stdout.txt"

TIMEOUT=2000
CHANNEL="dma0chan0"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "t:c:h" o; do
  case "$o" in
    t) TIMEOUT="${OPTARG}" ;;
    c) CHANNEL="${OPTARG}" ;;
    h|*) usage ;;
  esac
done

test_pdma() {
    info_msg "Running PDMA Test..."
    modprobe dmatest
    echo "$TIMEOUT" > /sys/module/dmatest/parameters/timeout
    echo 1 > /sys/module/dmatest/parameters/iterations
    echo "$CHANNEL" > /sys/module/dmatest/parameters/channel
    echo 1 > /sys/module/dmatest/parameters/run

    dmesg | grep dmatest | tee "$LOGFILE"
    if [ -n "$(sed -n '/dmatest: '$CHANNEL'-copy0: summary 1 tests, 0 failures/p' $LOGFILE)" ]; then
        report_pass "pdma-test"
    else
        report_fail "pdma-test"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_pdma

