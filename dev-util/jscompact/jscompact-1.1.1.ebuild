# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="jscompact is a text-mode program designed to compact javascript code and thereby speed download times."
HOMEPAGE="http://jscompact.sourceforge.net/"
SRC_URI="mirror://sourceforge/jscompact/${P}.tar.gz"

LICENSE="GPL2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-lang/spidermonkey"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.patch
}

src_compile() {
	exec ${S}/make
	ls ${S}
	if [ ! -e ${S}/jscompact ]; then die; fi
}

src_install() {
	dobin ${S}/jscompact || die
}

