#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib

OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE_speed="${OUTPUT}/stdout-ethernet-speed.txt"
LOGFILE_ping="${OUTPUT}/stdout-ethernet-ping.txt"

# Default ethernet interface
INTERFACE="eth0"
PING_ADDR="192.168.1.5"
MYTEST=false

usage() {
    echo "Usage: $0 [-i <ethernet-interface> -s <true|false>]" 1>&2
    exit 1
}

while getopts "s:i:p:m:h" o; do
  case "$o" in
    s) SKIP_INSTALL="${OPTARG}" ;;
    # Ethernet interface
    i) INTERFACE="${OPTARG}" ;;
    p) PING_ADDR="${OPTARG}" ;;
    m) MYTEST="${OPTARG}" ;;
    h|*) usage ;;
  esac
done

test_ethernet_change_speed() {
    info_msg "Running Verify Ethernet Connection and Communicaion after changed speed."

    echo MYTEST
    declare -A speed
    speed["10Mbps"]=10
    speed["100Mbps"]=100
    speed["1Gbps"]=1000

    pass_flag=true

    for KEY in "${!speed[@]}"; do
        echo $KEY

        ethtool -s $INTERFACE autoneg on duplex full speed ${speed[$KEY]} |& tee $LOGFILE_speed
        if [ -n "$(sed -n '/Cannot get current device settings/p' $LOGFILE_speed)" ]; then
            warn_msg "ethtool not working."
            pass_flag=false
            break
        fi
        sleep 5

        ping $PING_ADDR &
        exit_code="$?"
        if [ "${exit_code}" -ne 0 ]; then
            warn_msg "ping not working."
            pass_flag=false
            break
        fi

        sleep 3
        kill $!
    done

    if [ "$pass_flag" == "true" ]; then
        report_pass "verify-ethernet-after-changed-speed-test"
    else
        report_fail "verify-ethernet-after-changed-speed-test"
    fi

}

test_ethernet_ping_test() {
    info_msg "Running Verify Ethernet Connection and Communicaion by ping Test..."

    ifconfig $INTERFACE up; ifconfig $INTERFACE 192.168.1.1 netmask 255.255.255.0

    ping $PING_ADDR > $LOGFILE_ping &
    sleep 3
    kill $!

    if [ -n "$(sed -n '/64 bytes from/p' $LOGFILE_ping)" ]; then
        report_pass "verify-ethernet-connection-by-ping-test"
    else
        report_fail "verify-ethernet-connection-by-ping-test"
    fi
}

# Test run.
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"

pkgs="net-tools"
install_deps "${pkgs}" "${SKIP_INSTALL}"

if [ "$MYTEST" == "false" ]; then

    # Print all network interface status
    ip addr
    # Print given network interface status
    ip addr show "${INTERFACE}"

    # Get IP address of a given interface
    IP_ADDR=$(ip addr show "${INTERFACE}" | grep -a2 "state UP" | tail -1 | awk '{print $2}' | cut -f1 -d'/')

    [ -n "${IP_ADDR}" ]
    exit_on_fail "ethernet-ping-state-UP" "ethernet-ping-route"

    # Get default Route IP address of a given interface
    ROUTE_ADDR=$(ip route list  | grep default | awk '{print $3}' | head -1)

    # Run the test
    run_test_case "ping -c 5 ${ROUTE_ADDR}" "ethernet-ping-route"
else
    test_ethernet_ping_test
    test_ethernet_change_speed
fi
