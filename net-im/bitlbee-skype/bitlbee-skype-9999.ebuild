# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit git eutils

EGIT_REPO_URI="git://vmiklos.hu/bitlbee-skype"

DESCRIPTION="Skype plugin for Bitlbee"
HOMEPAGE="http://vmiklos.hu/project/bitlbee-skype/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# NOTE: These USE-flags control only dependencies, the presence of the
# required files is autodetected and skyped daemon and/or bitlbee
# plugin are built accordingly.
IUSE="daemon plugin"
DEPEND="daemon? ( >=net-im/skype-1.4.0.99
		>=dev-python/skype4py-0.9.28.7
		>=dev-python/pygobject-2.8.0
		dev-python/python-gnutls )
	plugin? ( >=net-im/bitlbee-1.2.3 )"

src_configure() {
	epatch "${FILESDIR}"/let-it-compile.patch

	make autogen
	./configure --prefix=/ --sysconfdir=/etc
}

src_install() {
	emake DESTDIR=${D} install || die
	dodoc HACKING NEWS README

	newinitd "${FILESDIR}"/skyped.initd skyped || die
	newconfd "${FILESDIR}"/skyped.confd skyped || die

	keepdir /var/run/skyped
	fowners nobody:nobody /var/run/skyped
}

pkg_postinst() {
	einfo
	elog "For basic configuration, please refer to the chapter 3.4"
	elog "in the project homepage:"
	elog "${HOMEPAGE}#_configuring"
	einfo
}
