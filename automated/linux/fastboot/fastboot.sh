#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE_lock="${OUTPUT}/fastboot-lock-stdout.txt"
LOGFILE_unlock="${OUTPUT}/fastboot-unlock-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "s:m:h" o; do
  case "$o" in
    m) MOUSE_DEVICE_NAME="${OPTARGS}" ;;
    s) STORAGE_DEVICE_NAME="${OPTARGS}" ;;
    h|*) usage ;;
  esac
done

test_fastboot_flashig_lock() {
    info_msg "Running Fastboot Flashing Lock Test..." | tee -a $LOGFILE_lock

    fastboot flash bootloader /opt/share/test/lk.bin 2>&1 | tee -a $LOGFILE_lock
    sleep 2
    fastboot flashing lock 2>&1 | tee -a $LOGFILE_lock
    sleep 2
    fastboot flashing unlock 2>&1 | tee -a $LOGFILE_lock
    sleep 2
    fastboot flashing lock 2>&1 | tee -a $LOGFILE_lock
    sleep 2
    fastboot erase a_bootloader 2>&1 | tee -a $LOGFILE_lock
    sleep 2
    fastboot flash bootloader /opt/share/test/lk.bin 2>&1 | tee -a $LOGFILE_lock
    sleep 2

    cnt=`grep -c 'Device is locked' $LOGFILE_lock`
    echo $cnt
    if [ "$cnt" -eq 2 ]; then
        report_pass "fastboot_flashing_lock"
    else
        report_fail "fastboot_flashing_lock"
    fi
}

test_fastboot_flashig_unlock() {
    info_msg "Running Fastboot Flashign Unlock Test..."

    fastboot flashing unlock 2>&1 | tee -a $LOGFILE_unlock
    sleep 2
    fastboot erase a_bootloader 2>&1 | tee -a $LOGFILE_unlock
    sleep 2
    fastboot flash bootloader /opt/share/test/lk.bin 2>&1 | tee -a $LOGFILE_unlock
    sleep 2
    fastboot flashing lock 2>&1 | tee -a $LOGFILE_unlock
    sleep 2

    cnt=$(grep -c 'OKAY' $LOGFILE_unlock)
    if [ $cnt -eq 3 ]; then
        report_pass "fastboot_flashing_unlock"
    else
        report_fail "fastboot_flashing_unlock"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_fastboot_flashig_lock
test_fastboot_flashig_unlock
