#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE1="${OUTPUT}/secure-os-stdout1.txt"
LOGFILE2="${OUTPUT}/secure-os-stdout2.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_secure_os_initialized() {
    info_msg "Running Verifying Secure OS Initialized Test..."
    dmesg | grep TEE | tee "$LOGFILE1"

    if [ -n "$(sed -n '/Trustonic TEE MTK, Build/p' $LOGFILE1)" ] && [ -n "$(sed -n '/MTK: t-base-Exynos_64/p' $LOGFILE1)" ] && [ -n "$(sed -n '/Trustonic TEE: check_version/p' $LOGFILE1)" ]; then
        report_pass "verify-secure-os-initilized-test"
    else
        report_fail "verify-secure-os-initilized-test"
    fi
}

test_secure_os_loaded() {
    info_msg "Running Verifying Secure OS Loaded Test..."
    ls -al /dev/ | grep mobi | tee "$LOGFILE2"

    if [ -n "$(sed -n '/mobicore/p' $LOGFILE2)" ] && [ -n "$(sed -n '/mobicore-user/p' $LOGFILE2)" ]; then
        report_pass "verify-secure-os-loaded-test"
    else
        report_fail "verify-secure-os-loaded-test"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_secure_os_initialized
test_secure_os_loaded

