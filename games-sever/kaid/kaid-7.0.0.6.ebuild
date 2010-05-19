# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

DESCRIPTION="XLink KAI -- link game consoles together over the internet (Supports XBox, Playstation 2, Gamecube and PSP)"
HOMEPAGE="http://www.teamxlink.co.uk/"
SRC_URI="http://www.teamxlink.co.uk/binary/${P}-linux_x86.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="-* x86"
IUSE=""

DEPEND=""
RDEPEND="virtual/libc"

S=${WORKDIR}/${PN}

src_compile() {
	echo "Nothing to compile, this is a binary."
}

src_install() {
	exeinto /usr/games/bin
	doexe kaid

	dodoc README

	insinto /etc
	doins kaid.conf

	exeinto /etc/init.d
	doexe ${FILESDIR}/kaid
}

