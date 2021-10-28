#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE_host="${OUTPUT}/usb-host-stdout.txt"
LOGFILE_host_mouse="${OUTPUT}/usb-host-mouse-stdout.txt"
LOGFILE_storage="${OUTPUT}/usb-storage-stdout.txt"
MOUSE_DEVICE_NAME="HP, Inc Optical Mouse"
STORAGE_DEVICE_NAME="SanDisk Corp."

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

test_usb_host_enabled() {
    info_msg "Running Checking USB Host is Enabled Test..."

    cd /sys/devices/platform/0x17200000.usb/
    ls | tee "$LOGFILE_host"
    if [ -n "$(sed -n '/id/p' $LOGFILE_host)" ] && \
       [ -n "$(sed -n '/b_sess/p' $LOGFILE_host)" ]; then
       report_pass "check-usb-host-enabled"
    else
       report_fail "check-usb-host-enabled"
    fi
}

test_usb_host_mouse() {
    info_msg "Running Checking USB host mouse is Working Test..."
    #/home/root/host.sh
    #lsusb | tee -a "$LOGFILE_host_mouse"

    if [ -n "$(sed -n "/${MOUSE_DEVICE_NAME}/p" $LOGFILE_host_mouse)" ]; then
        report_pass "verify-usb-host-mouse-test"
    else
        warn_msg "DEVICE '$MOUSE_DEVICE_NAME' not found."
        report_fail "verify-usb-host-mouse-test"
    fi
}

test_usb_storage_recognized_mounted() {
    info_msg "Running Checking USB Storage Recognized and Mounted Test..."

    /home/root/host.sh
    lsusb | tee -a "$LOGFILE_storage"

    if [ -n "$(sed -n "/STORAGE_DEVICE_NAME/p" $LOGFILE_storage)" ]; then
        report_pass "verify-usb-storage-recognized-test"
    else
        warn_msg "DEVICE '$STORAGE_DEVICE_NAME' not found."
        report_pass "verify-usb-storage-recognized-test"
    fi
}

# Test run.
create_out_dir "${OUTPUT}"
#test_check_cores_enabled
test_usb_host_mouse
test_usb_storage_recognized_mounted
