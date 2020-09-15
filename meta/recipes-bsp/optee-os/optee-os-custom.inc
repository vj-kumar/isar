# Custom OP-TEE OS build
#
# This software is a part of ISAR.
# Copyright (c) Siemens AG, 2020
#
# SPDX-License-Identifier: MIT

inherit dpkg

FILESEXTRAPATHS_prepend := "${FILE_DIRNAME}/files:"

SRC_URI += "file://debian/"

DESCRIPTION ?= "Custom OP-TEE OS"

OPTEE_NAME ?= "${MACHINE}"
OPTEE_PLATFORM ?= "unknown"
OPTEE_EXTRA_BUILDARGS ?= ""
OPTEE_BINARIES ?= "tee-pager_v2.bin"

DEBIAN_BUILD_DEPENDS ?= "python3-pycryptodome:native, python3-pyelftools"

PROVIDES += "optee-os-${OPTEE_NAME}"

TEMPLATE_FILES = "debian/control.tmpl"
TEMPLATE_VARS += "OPTEE_NAME DEBIAN_BUILD_DEPENDS"

do_prepare_build() {
    cp -r ${WORKDIR}/debian ${S}/

    deb_add_changelog

    rm -f ${S}/debian/optee-os-${OPTEE_NAME}.install
    for binary in ${OPTEE_BINARIES}; do
        echo "out/arm-plat-${OPTEE_PLATFORM}/core/$binary /usr/lib/optee-os/${OPTEE_NAME}/" >> \
            ${S}/debian/optee-os-${OPTEE_NAME}.install
    done
}

dpkg_runbuild_prepend() {
    export OPTEE_PLATFORM="${OPTEE_PLATFORM}"
    export OPTEE_EXTRA_BUILDARGS="${OPTEE_EXTRA_BUILDARGS}"
}