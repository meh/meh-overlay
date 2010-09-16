# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit nsplugins

DESCRIPTION="HURR FLASH DURR"
HOMEPAGE="http://labs.adobe.com/downloads/flashplayer10.html"
SRC_URI="http://download.macromedia.com/pub/labs/flashplayer10/flashplayer_square_p1_64bit_linux_091510.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	mkdir -p "${D}/usr/lib/flash-plugin"

	mv libflashplayer.so "${D}/usr/lib/flash-plugin"

	pushd "${D}/usr/lib/flash-plugin"
		exeinto /usr/lib/flash-plugin

		doexe libflashplayer.so
		inst_plugin /usr/lib/flash-plugin/libflashplayer.so
	popd
}
