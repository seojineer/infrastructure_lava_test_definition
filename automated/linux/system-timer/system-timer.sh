#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/system-timer-stdout.txt"

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

test_system_timer() {
    info_msg "Running System Timer Test..."
    dmesg | tee "$LOGFILE" &
    t=$!
    sleep 2
    kill $t

    sleep 2
    declare -a array
    cnt=0
    while read -r line; do {
        # shellcheck disable=SC2046
        time="$(echo "${line}" | awk '{print $2}' | tr -d ])"
        array[$cnt]=$time

        # to get timelog not 0.000000
        if [ $cnt -gt 150 ];then
            ret=`echo "${array[$(($cnt-1))]} ${array[$cnt]}" | awk '{if ($1 < $2) print 1; else print 0}'`
            if [ $ret -eq 1 ];then
                report_pass "system-timer-test"
            else
                report_fail "system-timer-test"
            fi
            break
        fi
        cnt=$(($cnt+1))
    } done < "$LOGFILE"

}

# Test run.
create_out_dir "${OUTPUT}"
test_system_timer

