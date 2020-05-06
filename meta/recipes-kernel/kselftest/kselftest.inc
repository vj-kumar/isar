# Kselftest package for Linux
#
# This software is a part of ISAR.
# Copyright (c) Mentor Graphics, a Siemens business, 2020
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DESCRIPTION ?= "Kernel selftests from Linux kernel ${PV}"

ISAR_CROSS_COMPILE = "0"

SRC_URI += "file://debian"
KSELFTEST_DEPENDS ?= " \
    rsync,  \
    flex,   \
    bison,  \
    "
KSELFTEST_TARGETS ?= ""
KSELFTEST_SKIP_TARGETS ?= ""
KSELFTEST_FORCE_TARGETS ?= "0"

inherit dpkg

TEMPLATE_FILES += "debian/control.tmpl \
                  debian/changelog.tmpl"
TEMPLATE_VARS += "KSELFTEST_DEPENDS"

do_prepare_build() {
    cp -rf ${WORKDIR}/debian ${S}/debian
}

dpkg_runbuild_prepend() {
    if [ -n "${KSELFTEST_TARGETS}" ];then
        export KSELFTEST_ARGS="TARGETS=\"${KSELFTEST_TARGETS}\""
    fi
    if [ "${KSELFTEST_FORCE_TARGETS}" ];then
        export KSELFTEST_ARGS="${KSELFTEST_ARGS} FORCE_TARGETS=1"
    fi
    if [ -n "${KSELFTEST_SKIP_TARGETS}" ];then
        export KSELFTEST_ARGS="${KSELFTEST_ARGS} SKIP_TARGETS=\"${KSELFTEST_SKIP_TARGETS}\""
    fi
}
