#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/smack-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_smack_policy_enabled() {
    info_msg "Running Verifying Smack Policy Enabled Test..."
    cat /sys/fs/smackfs/load2 | tee "$LOGFILE"

    # check /sys/fs/smackfs/load2
    if [ -n "$(sed '/System/p' $LOGFILE)" ] || [ -n "$(sed '/rwx/p' $LOGFILE)" ]; then
        info_msg "smack policy is enabled."
        if [ -e /sys/fs/smackfs/onlycap ]; then
            info_msg "/sys/fs/smackfs/load2 file exist."
            report_pass "verify-smack-policy-enabled"
        fi
    else
        warn_msg "smack policy is not enabled."
        report_fail "verify-smack-policy-enabled"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_smack_policy_enabled

