#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE_temperature="${OUTPUT}/dtm-stdout.txt"
LOGFILE_throttling_orig="${OUTPUT}/dtm-throttling-stdout.txt"
LOGFILE_throttling_new="${OUTPUT}/dtm-throttling-test-stdout.txt"
LOGFILE_cold_temperature_orig="${OUTPUT}/dtm-cold-temperature-stdout.txt"
LOGFILE_cold_temperature_new="${OUTPUT}/dtm-cold-temperature-test-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_verify_reading_current_temperature() {
    info_msg "Running Verify Reading current Temperature Test..."

    for ((index=0; index<5; index++)) do
        cat /sys/class/thermal/thermal_zone$index/temp | tee -a "$LOGFILE_temperature"
    done

    local pass_flag=true
    index=0
    while read -r line; do {
        temp="$(echo ${line})"
        if [ $temp -lt 16000 ] && [ $temp -gt 125000 ]; then
            pass_flag=false
            warn_msg "thermal_zone$index temperature: $temp. not in range 16000 ~ 125000."
        fi
        index=$(($index+1))
    } done < "$LOGFILE_temperature"

    if [ "$pass_flag" == "true" ]; then
        report_pass "verify-read-current-temperature-test"
    else
        report_fail "verify-read-current-temperature-test"
    fi
}

test_verify_throttling() {
    info_msg "Running Verify Throttling Test..."

    cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq | tee "$LOGFILE_throttling_orig"

    for ((i=0; i<2; i++)); do
        echo 20000 > /sys/class/thermal/thermal_zone$i/emul_temp
        echo 95000 > /sys/class/thermal/thermal_zone$i/emul_temp
        echo 115000 > /sys/class/thermal/thermal_zone$i/emul_temp
        echo 120000 > /sys/class/thermal/thermal_zone$i/emul_temp
    done

    cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq | tee "$LOGFILE_throttling_new"

    diff "$LOGFILE_throttling_orig" "$LOGFILE_throttling_new"
    check_return "verify-throttling-test"
}

test_verify_cold_temperature() {
    info_msg "Running Verify Cold Temperature Test..."

    cd /sys/class/regulator

    info_msg "Get current set regulator target voltage"
    echo "No Name min-voltage target-voltage max-voltage" | tee -a "$LOGFILE_cold_temperature_orig"
    i=3
    while [ 1 ]; do
        if [ $i -gt 43 ]; then
            break
        fi
        echo "$i: $(cat ./regulator.$i/name) $(cat ./regulator.$i/min_microvolts) \
        <- $(cat ./regulator.$i/microvolts) -> $(cat ./regulator.$i/max_microvolts)" \
        | tee -a "$LOGFILE_cold_temperature_orig"
        i=$(($i+1))
    done

    info_msg "Set the lower temperature through sysfs node"
    echo 12000 > /sys/class/thermal/thermal_zone0/emul_temp

    info_msg "Read temperature through sysfs node"
    cat /sys/class/thermal/thermal_zone0/temp

    info_msg "Get current set regulator target voltage"
    echo "No Name min-voltage target-voltage max-voltage" > $LOGFILE_cold_temperature_new
    i=3
    while [ 1 ]; do
        if [ $i -gt 43 ]; then
            break
        fi
        echo "$i: $(cat ./regulator.$i/name) $(cat ./regulator.$i/min_microvolts) \
        <- $(cat ./regulator.$i/microvolts) -> $(cat ./regulator.$i/max_microvolts)" \
        | tee -a "$LOGFILE_cold_temperature_new"
        i=$(($i+1))
    done

    info_msg "Parse log files"
    declare -A orig
    while read -r line; do {
        if [[ $line =~ "No such file or directory" ]] || [[ $line =~ "Name" ]]; then
            continue
        fi
        name="$(echo "${line}" | awk '{print $2}')"
        target_voltage="$(echo "${line}" | awk '{print $5}')"
        if [ ! $target_voltage ];then
            continue
        fi
        orig["$name"]=$target_voltage
    } done < "$LOGFILE_cold_temperature_orig"

    declare -A new
    while read -r line; do {
        if [[ $line =~ "No such file or directory" ]] || [[ $line =~ "Name" ]]; then
            continue
        fi
        name="$(echo "${line}" | awk '{print $2}')"
        target_voltage="$(echo "${line}" | awk '{print $5}')"
        if [ ! $target_voltage ];then
            continue
        fi
        new["$name"]=$target_voltage
    } done < "$LOGFILE_cold_temperature_new"

    # Check if only nodes of which voltage is changed make sure that the 25mV voltage is higher than before.
    local pass_flag=true
    for name in ${!orig[@]}; do
        if [ ${orig["$name"]} -eq ${new["$name"]} ]; then
            continue
        elif [ `expr ${new["$name"]} - ${orig["$name"]}` -ne 25000 ]; then
            pass_flag=false
            warn_msg "voltage of $name node is not 25mV higher than before."
            warn_msg "voltage: ${new["$name"]}, voltage before test: ${orig["$name"]}"
        fi
    done
    if [ "$pass_flag" == "true" ]; then
        report_pass "verify-cold_temperature-test"
    else
        report_fail "verify-cold_temperature-test"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_verify_reading_current_temperature
test_verify_throttling
test_verify_cold_temperature
