#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/runtime-pm-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_verify_runtime_pm() {
    info_msg "Running Verifying Runtime PM Framework Test..."
    array=("dbgdev-pd-aud" "dbgdev-pd-mfc" "dbgdev-pd-npu00" "dbgdev-pd-taa0" "dbgdev-pd-g3d00" "dbgdev-pd-dpus0")

    # Enable runtime pm
    for unit in ${array[@]}; do
        echo 1 > /sys/kernel/debug/exynos-pd/$unit
    done
    sleep 5

    # Disable runtime pm
    for unit in ${array[@]}; do
        echo 0 > /sys/kernel/debug/exynos-pd/$unit
    done

    dmesg | grep exynos_pd_dbg | tee "$LOGFILE"
    tail -n ${#array[@]} "$LOGFILE" | tee "$LOGFILE"

    cnt=0
    check_string="Runtime_Resume"

    while read -r line; do {
	name="$(echo "${line}" | awk '{print $(NF-1)}' | tr -d :)"
	string="$(echo "${line}" | awk '{print $(NF)}')"
	if [ "$name" == "${array[$cnt]}" ]; then
	    if [ "$string" != "$check_string" ]; then
	       report_fail "verify-runtime-pm-framework-test"
	       error_msg "$name is not set properly."
	    fi
	else
	   report_fail "verify-runtime-pm-framework-test"
	   error_msg "expected ${array[$cnt]}, but no log shown."
	fi

	cnt=$(($cnt+1))
	if [ $cnt -eq ${#array[@]} ]; then
            cnt=0
            check_string="Runtime_Suspend"
	fi
    } done < "$LOGFILE"
    report_pass "verify-runtime-pm-framework-test"

}

# Test run.
create_out_dir "${OUTPUT}"
test_verify_runtime_pm
