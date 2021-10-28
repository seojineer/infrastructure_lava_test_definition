#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
LOGFILE="${OUTPUT}/spi-stdout.txt"
TEST_LOG="spi-test-log.txt"
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

# TC Auto9-52181
test_spi_master_mode1() {
    info_msg "Running Verify Master Mode Transfer over SPI Test1..."

    echo 0 > /sys/devices/platform/10900000.spi/spi_dbg
    spidev_test -D /dev/spidev1.0 -v -s 25000000
    check_return "verify-spi-master-mode-test1"
}

# TC Auto9-55268
test_spi_master_mode2() {
    info_msg "Running Verify Master Mode Transfer over SPI Test2..."

    echo 0 > /sys/devices/platform/10900000.spi/spi_dbg
    spidev_test -D /dev/spidev1.0 -s 25000000 -S 4096 -I 100 | tee $LOGFILE
    diff $LOGFILE $TEST_LOG
    check_return "verify-spi-master-mode-test2"
}

# Test run.
create_out_dir "${OUTPUT}"

test_spi_master_mode1
test_spi_master_mode2
