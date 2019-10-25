# This software is a part of ISAR.
# Copyright (C) 2019 Siemens AG
#
# SPDX-License-Identifier: MIT

deb_dl_dir_import() {
    export pc="${DEBDIR}/${DISTRO}"
    export rootfs="${1}"
    [ ! -d "${pc}" ] && return 0
    flock -s "${pc}".lock -c ' \
        sudo find "${pc}" -type f -iname '*\.deb' -exec \
            cp -f --no-preserve=owner -t "${rootfs}"/var/cache/apt/archives/ '{}' +
    '
}

deb_dl_dir_export() {
    export pc="${DEBDIR}/${DISTRO}"
    export rootfs="${1}"
    mkdir -p "${pc}"
    flock "${pc}".lock -c ' \
        sudo find "${rootfs}"/var/cache/apt/archives/ -type f -iname '*\.deb' \
            -exec cp -f '{}' "${pc}" \;
        sudo chown -R $(id -u):$(id -g) "${pc}"
    '
}
