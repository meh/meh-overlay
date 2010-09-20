# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit games

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://linux.toribash.com/download/amd64/toribash-3.50-amd64.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	mkdir -p "${D}"/opt/

	mv toribash* "${D}"/opt/toribash

	dogamesbin "${D}"/opt/toribash/toribash
}
