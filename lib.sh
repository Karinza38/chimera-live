#!/bin/sh
#
# Shared functions to be used by image creation scripts.
#
# Copyright 2022 q66 <q66@chimera-linux.org>
#
# License: BSD-2-Clause
#

umask 022

readonly PROGNAME=$(basename "$0")

mount_pseudo() {
    mount -t devtmpfs none "${ROOT_DIR}/dev" || die "failed to mount devfs"
    mount -t proc none "${ROOT_DIR}/proc" || die "failed to mount procfs"
    mount -t sysfs none "${ROOT_DIR}/sys" || die "failed to mount sysfs"
}

mount_pseudo_host() {
    mount -t devtmpfs none "${HOST_DIR}/dev" || die "failed to mount devfs"
    mount -t proc none "${HOST_DIR}/proc" || die "failed to mount procfs"
    mount -t sysfs none "${HOST_DIR}/sys" || die "failed to mount sysfs"
}

umount_pseudo_dir() {
    [ -n "$1" -a -d "$1" ] || return 0
    umount -f "${1}/dev" > /dev/null 2>&1
    umount -f "${1}/proc" > /dev/null 2>&1
    umount -f "${1}/sys" > /dev/null 2>&1
    umount -f "${1}/mnt" > /dev/null 2>&1
    mountpoint -q "${1}" > /dev/null 2>&1 && \
        umount -f "${1}" > /dev/null 2>&1
}

umount_pseudo() {
    sync
    umount_pseudo_dir "$HOST_DIR"
    umount_pseudo_dir "$ROOT_DIR"
}

error_sig() {
    umount_pseudo
    exit ${1:=0}
}

trap 'error_sig $? $LINENO' INT TERM 0

msg() {
    printf "\033[1m$@\n\033[m"
}

die() {
    msg "ERROR: $@"
    error_sig 1 $LINENO
}

if [ "$(id -u)" != "0" ]; then
    die "must be run as root"
fi
