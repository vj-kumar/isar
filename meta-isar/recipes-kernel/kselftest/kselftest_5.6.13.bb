# Kselftest package
#
# This software is a part of ISAR.
# Copyright (c) Mentor Graphics, a Siemens business, 2020
#
# SPDX-License-Identifier: MIT

require recipes-kernel/kselftest/kselftest.inc

KSELFTEST_DEPENDS += " \
    libelf-dev:native, \
    libcap-ng-dev:native, \
    libpopt-dev:native, \
    libcap-dev:native, \
    libmount-dev:native, \
    libnuma-dev:native, \
    libfuse-dev:native, \
    libmnl-dev:native, \
    pkg-config, \
    "
KSELFTEST_FORCE_TARGETS="1"
KSELFTEST_SKIP_TARGETS="bpf"
KSELFTEST_SKIP_TARGETS_armhf="bpf kvm kexec"
KSELFTEST_SKIP_TARGETS_arm64="bpf kexec breakpoints"
KSELFTEST_SKIP_TARGETS_i386="bpf kvm"
SRC_URI += "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${PV}.tar.xz"
SRC_URI[sha256sum] = "f125d79c8f6974213638787adcad6b575bbd35a05851802fd83f622ec18ff987"

S = "${WORKDIR}/linux-${PV}"
