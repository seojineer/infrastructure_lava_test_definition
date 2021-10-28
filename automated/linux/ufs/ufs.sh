#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/ufs-stdout.txt"

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while getopts "h" o; do
  case "$o" in
    h|*) usage ;;
  esac
done

test_ufs_fs_mount() {
    info_msg "Running UFS Filesystem Mount Test..."
    echo y | mkfs.ext4 /dev/disk/by-partlabel/ramdump
    mkdir /test
    mount -t ext4 /dev/disk/by-partlabel/ramdump /test
    mount | grep test | tee "$LOGFILE"

    if [ -n "$(sed -n '/test type ext4/p' $LOGFILE)" ]; then
        report_pass "ufs-fs-mount-test"
    else
        report_fail "ufs-fs-mount-test"
    fi
}

test_ufs_raw_read_test1() {
    info_msg "Running UFS raw Read Test..."
    dd if=/dev/sda of=/dev/null bs=64k count=400
    check_return "ufs-raw-read-test1"
}

test_ufs_raw_read_test2() {
    info_msg "Running UFS raw Read Test..."
    dd if=/dev/disk/by-partlabel/partition_info of=/dev/null bs=64k count=400
    check_return "ufs-raw-read-test2"
}

# Test run.
create_out_dir "${OUTPUT}"
test_ufs_fs_mount
test_ufs_raw_read_test1
test_ufs_raw_read_test2
