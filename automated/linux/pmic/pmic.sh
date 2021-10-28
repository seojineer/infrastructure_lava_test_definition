#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE_regulator="${OUTPUT}/pmic-regulator-stdout.txt"
LOGFILE_rtc="${OUTPUT}/pmic-rtc-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_regulator_pmic() {
    info_msg "Running Verifying Regulators Initilized and PMIC driver Test..."
    cat /sys/kernel/debug/regulator/regulator_summary | tee "$LOGFILE_regulator"
    sed -i '1,2d' "$LOGFILE_regulator"

    result="pass"

    while read -r line; do {
        regulator="$(echo "${line}" | awk '{print $1}')"
        voltage_value="$(echo "${line}" | awk '{print $(NF-3)}' | tr -d mV)"
        min="$(echo "${line}" | awk '{print $(NF-1)}' | tr -d mV)"
        max="$(echo "${line}" | awk '{print $(NF)}' | tr -d mV)"
        columns="$(echo $line | awk '{print NF}')"

        if [ $columns -lt 9 ]; then
            warn_msg "$regulator have no voltage value."
        elif [ $min -le $voltage_value ] && [ $voltage_value -le $max ]; then
            # Check if voltage value of each items are between the min value and the max value
            info_msg "$regulator voltage: $voltage_value, min: $min, max: $max"
        else
            warn_msg "$regulator voltage: $voltage_value, min: $min, max: $max"
            result="fail"
        fi
    } done < "$LOGFILE_regulator"

    if [ "$result" == "pass" ]; then
        report_pass "regulator-pmic-verify-voltage-test"
    else
        report_fail "regulator-pmic-verify-voltage-test"
    fi
}

test_rtc() {
    info_msg "Running Check RTC driver working Test..."

    echo +3 > /sys/class/rtc/rtc0/wakealarm; sleep 5
    dmesg | grep s2vps01-rtc | tee "$LOGFILE_rtc"
    tail -n 8 "$LOGFILE_rtc" | tee "$LOGFILE_rtc"

    if [ -n "$(sed -n '/s2m_rtc_alarm_irq/p' $LOGFILE_rtc)" ]; then
        report_pass "rtc-driver-working-test"
    else
        report_fail "rtc-driver-working-test"
    fi

}

# Test run.
create_out_dir "${OUTPUT}"
test_regulator_pmic
test_rtc

