#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/video-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_rvc_priority_feature_and_video_regression() {
    info_msg "Running RVC Priority Feature and Video Regression Test..."

    cd /usr/share; ./video-regression.sh | tee "$LOGFILE"

    if [ -n "$(sed -n '/8 Decoders & 2 Encoders PASSED/p' $LOGFILE)" ] && [ -n "$(sed -n '/0 Decoders & 0 Encoders FAILED/p' $LOGFILE)" ]; then
        report_pass "rvc-priority-feature-and-video-regression"
    else
        report_fail "rvc-priority-feature-and-video-regression"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
test_rvc_priority_feature_and_video_regression
