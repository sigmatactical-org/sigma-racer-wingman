#!/bin/sh
# Bring up Linux SocketCAN on FLEXCAN2 (Verdin CAN_2 / can1).
# FLEXCAN1 is owned by the M7 safety core — see sigma-racer-sidearm.
# Defaults: 500 kbit/s classical CAN, no FD, listen-only (passive tap).
set -eu

IFACE="${SIGMA_RACER_WINGMAN_CAN_IFACE:-can1}"
BITRATE="${SIGMA_RACER_WINGMAN_CAN_BITRATE:-500000}"
FD="${SIGMA_RACER_WINGMAN_CAN_FD:-off}"
LISTEN_ONLY="${SIGMA_RACER_WINGMAN_CAN_LISTEN_ONLY:-on}"

if ! ip link show "$IFACE" >/dev/null 2>&1; then
    echo "can-setup: interface $IFACE not found" >&2
    exit 1
fi

ip link set "$IFACE" down 2>/dev/null || true

# Build the config incrementally so classical vs FD and listen-only stay optional.
CANARGS="type can bitrate $BITRATE"
[ "$FD" = "on" ] && CANARGS="$CANARGS fd on"
[ "$LISTEN_ONLY" = "on" ] && CANARGS="$CANARGS listen-only on"
# shellcheck disable=SC2086 # intentional word-splitting of the built arg list
ip link set "$IFACE" $CANARGS

ip link set "$IFACE" up
