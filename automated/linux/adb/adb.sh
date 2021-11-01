#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/adb-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts ":h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_adb() {
    info_msg "Running Verifying ADB is push, pull is Working Test..."

    # ADB push test
    pass_flag=true
    touch local_file
    adb push local_file /tmp | tee $LOGFILE
    if [ -n "$(sed -n '/no devices/p' $LOGFILE)" ]; then
        pass_flag=false
    fi

    adb shell ls /tmp/local_file | tee -a $LOGFILE
    if [ -n "$(sed -n '/no devices/p' $LOGFILE)" ] \
    || [ -n "$(sed -n '/No such file or directory/p' $LOGFILE)" ]; then
        pass_flag=false
    fi

    if [ "$pass_flag" == "true" ]; then
        report_pass "adb-push-test"
    else
        report_fail "adb-push-test"
    fi

    # ADB pull test
    adb pull /data/machine-id  .
    ls machine-id
    exit_on_fail "adb-pull-test"
}

# Test run.
create_out_dir "${OUTPUT}"
test_adb
