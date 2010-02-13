# Copyright 1999-2003 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion eutils

IUSE="acpi ipv6 gps"

DESCRIPTION="Wireless detection program - CVS ebuild."
HOMEPAGE="http://kismetwireless.net/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"

DEPEND="!net-wireless/kismet
		gps? ( >=dev-libs/expat-1.95.4 media-gfx/imagemagick )"

S=${WORKDIR}/${PN}/trunk

src_unpack() {
		cd ${WORKDIR}
		mkdir kismet-devel

		ESVN_REPO_URI="https://www.kismetwireless.net/code/svn/trunk"
		ESVN_PROJECT="kismet-devel"
		subversion_src_unpack

		if [ -n "`use ethereal`" ]; then
			unpack ethereal-0.9.13.tar.bz2
		fi
}

src_compile() {
		local myconf

		use gps || myconf="${myconf} --disable-gps"

		if [ -n "`use ethereal`" ]; then
			myconf="${myconf} --with-ethereal=${MY_WORKDIR}/ethereal-0.9.13"
			cd ${MY_WORKDIR}/ethereal-0.9.13/wiretap
			econf || die
			emake || die
		fi

		cd ${S}
		./configure \
			--prefix=/usr \
			--host=${CHOST} \
			--mandir=/usr/share/man \
			--infodir=/usr/share/info \
			--datadir=/usr/share \
			--sysconfdir=/etc/ \
			--localstatedir=/var/lib \
			${myconf} || die "./configure failed"

		cd ${S}/conf
		cp -f kismet.conf kismet.conf.orig
		cp -f kismet_ui.conf kismet_ui.conf.orig
		sed -e "s:/usr/local:/usr:g; \
				s:=ap_manuf:=/etc/ap_manuf:g; \
				s:=client_manuf:=/etc/client_manuf:g" \
			kismet.conf.orig > kismet.conf
		sed -e "s:/usr/local:/usr:g" kismet_ui.conf.orig > kismet_ui.conf
		rm -f kismet.conf.orig kismet_ui.conf.orig

		cd ${S}
		make dep || die "make dep for kismet failed"
		emake || die "compile of kismet failed"
}

src_install() {
	dodir /usr/bin
	make prefix=${D}/usr \
		ETC=${D}/etc/ MAN=${D}/usr/share/man \
		SHARE=${D}/usr/share/${P} install || die
	dodoc CHANGELOG FAQ README docs/*

}
