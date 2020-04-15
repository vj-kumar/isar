# This software is a part of ISAR.
# Copyright (C) 2020 Siemens AG
#
# SPDX-License-Identifier: MIT

inherit repository

check_in_rootfs() {
    local package="$( dpkg-deb --show --showformat '${Package}' "${1}" )"
    local output="$( grep -hs "^Package: ${package}" \
            "${IMAGE_ROOTFS}"/var/lib/dpkg/status \
            "${BUILDCHROOT_HOST_DIR}"/var/lib/dpkg/status \
            "${BUILDCHROOT_TARGET_DIR}"/var/lib/dpkg/status )"
    [ -z "${output}" ] && return 1 || return 0
}

debsrc_download() {
    export rootfs="$1"
    export rootfs_distro="$2"
    mkdir -p "${DEBSRCDIR}"/"${rootfs_distro}"
    ( flock 9
    set -e
    printenv | grep -q BB_VERBOSE_LOGS && set -x
    sudo -E -s <<'EOSUDO'
    mkdir -p "${rootfs}/deb-src"
    mountpoint -q "${rootfs}/deb-src" || \
    mount --bind "${DEBSRCDIR}" "${rootfs}/deb-src"
EOSUDO
    find "${rootfs}/var/cache/apt/archives/" -maxdepth 1 -type f -iname '*\.deb' | while read package; do
        check_in_rootfs "${package}" || continue
        local src="$( dpkg-deb --show --showformat '${Source}' "${package}" )"
        # If the binary package version and source package version are different, then the
        # source package version will be present inside "()" of the Source field.
        local version="$( echo "$src" | cut -sd "(" -f2 | cut -sd ")" -f1 )"
        if [ -z ${version} ]; then
            version="$( dpkg-deb --show --showformat '${Version}' "${package}" )"
        fi
        # Now strip any version information that might be available.
        src="$( echo "$src" | cut -d' ' -f1 )"
        # If there is no source field, then the source package has the same name as the
        # binary package.
        if [ -z "${src}" ];then
            src="$( dpkg-deb --show --showformat '${Package}' "${package}" )"
        fi
        # Strip epoch, if any, from version.
        local dscfile=$(find "${DEBSRCDIR}"/"${rootfs_distro}" -name "${src}_${version#*:}.dsc")
        [ -z "$dscfile" ] || continue

        sudo -E chroot --userspec=$( id -u ):$( id -g ) ${rootfs} \
            sh -c ' mkdir -p "/deb-src/${1}/${2}" && cd "/deb-src/${1}/${2}" && apt-get -y --download-only --only-source source "$2"="$3" ' download-src "${rootfs_distro}" "${src}" "${version}"
    done
    sudo -E -s <<'EOSUDO'
    mountpoint -q "${rootfs}/deb-src" && \
    umount -l "${rootfs}/deb-src"
    rm -rf "${rootfs}/deb-src"
EOSUDO
    ) 9>"${DEBSRCDIR}/${rootfs_distro}.lock"
}

deb_dl_dir_import() {
    export pc="${DEBDIR}/${2}"
    export rootfs="${1}"
    [ ! -d "${pc}" ] && return 0
    sudo mkdir -p "${rootfs}"/var/cache/apt/archives/
    flock -s "${pc}".lock -c '
        set -e
        printenv | grep -q BB_VERBOSE_LOGS && set -x

        sudo find "${pc}" -type f -iname '*\.deb' -exec \
            cp -n --no-preserve=owner -t "${rootfs}"/var/cache/apt/archives/ '{}' +
    '
}

deb_dl_dir_export() {
    export pc="${DEBDIR}/${2}"
    export rootfs="${1}"
    mkdir -p "${pc}"
    flock "${pc}".lock -c '
        set -e
        printenv | grep -q BB_VERBOSE_LOGS && set -x

        find "${rootfs}"/var/cache/apt/archives/ \
            -maxdepth 1 -type f -iname '*\.deb' |\
        while read p; do
            # skip files from a previous export
            [ -f "${pc}/${p##*/}" ] && continue
            # can not reuse bitbake function here, this is basically
            # "repo_contains_package"
            package=$(find "${REPO_ISAR_DIR}"/"${DISTRO}" -name ${p##*/})
            if [ -n "$package" ]; then
                cmp --silent "$package" "$p" && continue
            fi
            sudo cp -n "${p}" "${pc}"
        done
        sudo chown -R $(id -u):$(id -g) "${pc}"
    '
}
