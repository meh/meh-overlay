# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A decentralized, anarchic replacement of the Internet"
HOMEPAGE="http://netsukuku.freaknet.org/"
#SRC_URI="http://netsukuku.freaknet.org/${P}.tar.bz2"
SRC_URI="mirror://sourceforge/netsukuku/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc wifi"

DEPEND="dev-libs/gmp
        dev-libs/openssl
        wifi? ( net-wireless/wireless-tools )"

src_install() {
    emake DESTDIR="${D}" install || die "make install failed"
    if ! use wifi ; then
        rm "${D}/usr/bin/netsukuku_wifi"
        rm "${D}/usr/share/man/man8/netsukuku_wifi.8"
    fi
    dodoc ChangeLog README AUTHORS
    if use doc ; then
        dodoc src/TODO doc/* 
        docinto howto
        dodoc doc/howto/*
        docinto manuals
        dodoc doc/manuals/*
        docinto protocol
        dodoc doc/protocol/*
    fi
}
