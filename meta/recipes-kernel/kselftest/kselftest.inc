# Kselftest package for Linux
#
# This software is a part of ISAR.
# Copyright (c) Mentor Graphics, a Siemens Business, 2020
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# Some test-cases like memfd compilation failed in cross-compilation.
# Force native compilation for now to have consistent output across
# ISAR native/cross compilation setups.
ISAR_CROSS_COMPILE = "0"

DESCRIPTION ?= "Kernel selftests from Linux kernel ${PV}"

DEBIAN_BUILD_DEPENDS ?= " \
    rsync, \
    flex,  \
    bison, \
    fuse, \
    libelf-dev:native, \
    libcap-ng-dev:native, \
    libpopt-dev:native, \
    libcap-dev:native, \
    libmount-dev:native, \
    libnuma-dev:native, \
    libfuse-dev:native, \
    libmnl-dev:native, \
    pkg-config, \
    clang:native, \
    llvm:native, \
"

SRC_URI += "file://debian"
S = "${WORKDIR}/linux-${PV}"

KSELFTEST_TARGETS ?= ""
KSELFTEST_SKIP_TARGETS ?= ""
KSELFTEST_FORCE_TARGETS ?= "0"

inherit dpkg

do_prepare_build() {
    cp -rf ${WORKDIR}/debian ${S}/debian
    deb_create_compat
    deb_create_control
    deb_add_changelog
}

dpkg_runbuild_prepend() {
    if [ -n "${KSELFTEST_TARGETS}" ];then
        export KSELFTEST_ARGS="TARGETS=\"${KSELFTEST_TARGETS}\""
    fi
    if [ ${KSELFTEST_FORCE_TARGETS} -eq 1 ];then
        export KSELFTEST_ARGS="${KSELFTEST_ARGS} FORCE_TARGETS=1"
    fi
    if [ -n "${KSELFTEST_SKIP_TARGETS}" ];then
        export KSELFTEST_ARGS="${KSELFTEST_ARGS} SKIP_TARGETS=\"${KSELFTEST_SKIP_TARGETS}\""
    fi
}
