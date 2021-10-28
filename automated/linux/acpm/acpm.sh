#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/acpm-stdout.txt"
LOGFILE_plugin="${OUTPUT}/acpm-plugin-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_acpm_ipc_driver() {
    info_msg "Running ACPM IPC Driver Test..."
    array=("irq_num" "ipc_sq_i" "fw_ipc+" "fw_ipc-" "ipc_sq_o" "latencyo")

    echo -n 1 > /sys/kernel/debug/acpm_framework/log_level
    cat /sys/kernel/debug/acpm_framework/ipc_loopback_test
    echo -n 0 > /sys/kernel/debug/acpm_framework/log_level

    dmesg | grep ACPM | tee "$LOGFILE"

    for data in ${array[@]}; do
        if [ ! -n "$(sed -n "/$data/p" "$LOGFILE")" ]; then
            report_fail "acpm-ipc-driver-test"
            warn_msg "$data is not shown in log."
            break
        fi
    done
    report_pass "acpm-ipc-driver-test"
}

test_acpm_plugin_init() {
    info_msg "Running ACPM Plugin Init Test..."
    array=("Plugin0 - Framework" "Plugin1 - SCI" "Plugin2 - FVP" "Plugin3 - MFD" "Plugin4 - DVFS" "Plugin5 - FullSWPMU" "Plugin6 - TMU" "Plugin7 - FlexPMU")

    cat /sys/kernel/debug/acpm_framework/plugin_info
    dmesg | grep exynos-acpm | grep Plugin | tee "$LOGFILE_plugin"
    tail -n ${#array[@]} "$LOGFILE_plugin" | tee "$LOGFILE_plugin"

    pass_flag=true
    for data in "${array[@]}"; do
        if [ ! -n "$(sed -n "/$data/p" "$LOGFILE_plugin")" ];then
	    pass_flag=false
            warn_msg "$data is not shown in log."
        fi
    done
    if [ "$pass_flag" == "false" ]; then
        report_fail "acpm-plugin-init-test"
    else
        report_pass "acpm-plugin-init-test"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_acpm_ipc_driver
test_acpm_plugin_init

