# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit java-pkg-2


DESCRIPTION="YUI Compressor"
HOMEPAGE=""
SRC_URI="http://yuilibrary.com/downloads/yuicompressor/yuicompressor-${PV}.zip"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

src_compile() {
	echo HURR DURR
}

src_install() {
	java-pkg_newjar build/yuicompressor-2.4.2.jar yuicompressor.jar

	java-pkg_dolauncher yuicompressor --jar yuicompressor.jar
}
