# This software is a part of ISAR.
# Copyright (C) Siemens AG, 2019
#
# SPDX-License-Identifier: MIT
#
# This class extends the image.bbclass to supply the creation of cache repositories

inherit base-apt-helper

do_cache_base_repo[depends] = "base-apt:do_cache_config"
do_cache_base_repo[lockfiles] = "${REPO_BASE_DIR}/isar.lock"
do_cache_base_repo[stamp-extra-info] = "${DISTRO}-${MACHINE}"
do_cache_base_repo() {
    if [ -d '${BUILDCHROOT_HOST_DIR}/var/cache/apt' ] &&
        [ '${DISTRO}' != '${HOST_DISTRO}' ]; then
        # We would need two separate repository paths for that.
        # Otherwise packages (especially the 'all' arch ones) from one
        # distribution can influence the package versions of the other
        # distribution.
        bbfatal "Different host and target distributions are currently not supported." \
                "Try it without cross-build."
    fi

    if [ -d ${WORKDIR}/apt_cache ]; then
        populate_base_apt ${WORKDIR}/apt_cache
    fi

    if [ -d ${BUILDCHROOT_HOST_DIR}/var/cache/apt ]; then
        populate_base_apt ${BUILDCHROOT_HOST_DIR}/var/cache/apt
    fi

    if [ -d ${BUILDCHROOT_TARGET_DIR}/var/cache/apt ]; then
        populate_base_apt ${BUILDCHROOT_TARGET_DIR}/var/cache/apt
    fi

    if [ -d "${DEBSRCDIR}"/"${DISTRO}" ]; then
        populate_base_apt "${DEBSRCDIR}"/"${DISTRO}"
    fi
}
addtask cache_base_repo after do_rootfs do_install_imager_deps
