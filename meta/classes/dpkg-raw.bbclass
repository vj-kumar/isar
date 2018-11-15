# This software is a part of ISAR.
# Copyright (C) 2017-2018 Siemens AG

inherit dpkg

DEBIAN_DEPENDS ?= ""
MAINTAINER ?= "Unknown maintainer <unknown@example.com>"

D = "${S}"

# Populate folder that will be picked up as package
do_install() {
	bbnote "Put your files for this package in ${D}"
}

do_install[cleandirs] = "${D}"
do_install[stamp-extra-info] = "${DISTRO}-${DISTRO_ARCH}"
addtask install after do_unpack before do_prepare_build

deb_add_changelog() {
	date=$( LANG=C date -R )
	cat <<EOF > ${D}/debian/changelog
${PN} (${PV}) UNRELEASED; urgency=low

  * generated by Isar

 -- ${MAINTAINER}  ${date}
EOF
	if [ -f ${WORKDIR}/changelog ]; then
		echo >> ${D}/debian/changelog
		cat ${WORKDIR}/changelog >> ${D}/debian/changelog
	fi
}

deb_create_compat() {
	echo 9 > ${D}/debian/compat
}

deb_create_control() {
	compat=$( cat ${D}/debian/compat )
	cat << EOF > ${D}/debian/control
Source: ${PN}
Section: misc
Priority: optional
Standards-Version: 3.9.6
Maintainer: ${MAINTAINER}
Build-Depends: debhelper (>= ${compat})

Package: ${PN}
Architecture: any
Depends: ${DEBIAN_DEPENDS}
Description: ${DESCRIPTION}
EOF
}

deb_create_rules() {
	cat << EOF > ${S}/debian/rules
#!/usr/bin/make -f
%:
	dh \$@

EOF
	chmod +x ${S}/debian/rules
}

deb_debianize() {
	if [ -f ${WORKDIR}/compat ]; then
		install -v -m 644 ${WORKDIR}/compat ${D}/debian/compat
	else
		deb_create_compat
	fi
	if [ -f ${WORKDIR}/control ]; then
		install -v -m 644 ${WORKDIR}/control ${D}/debian/control
	else
		deb_create_control
	fi
	if [ -f ${WORKDIR}/rules ]; then
		install -v -m 755 ${WORKDIR}/rules ${D}/debian/rules
	else
		deb_create_rules
	fi
	deb_add_changelog

	for t in pre post
	do
		for a in inst rm
		do
			if [ -f ${WORKDIR}/${t}${a} ]; then
				install -v -m 755 ${WORKDIR}/${t}${a} \
					${D}/debian/${t}${a}
			fi
		done
	done
}

do_prepare_build[cleandirs] += "${D}/debian"
do_prepare_build() {
	cd ${D}
	find . ! -type d | sed 's:^./::' > ${WORKDIR}/${PN}.install
	mv ${WORKDIR}/${PN}.install ${D}/debian/

	deb_debianize
}
