# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A cool CLI packet sniffer"
HOMEPAGE="http://blacklight.gotdns.org"
SRC_URI="http://blacklight.gotdns.org/prog/tcpsmash/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="net-libs/libpcap"

src_compile() {
	emake || die "Compilation failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
