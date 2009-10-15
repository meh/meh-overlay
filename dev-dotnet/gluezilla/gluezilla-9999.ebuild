# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion
ESVN_REPO_URI="svn://anonsvn.mono-project.com/source/trunk/gluezilla"
ESVN_PROJECT="libgluezilla-snapshot"
ESVN_BOOTSTRAP="autogen.sh"

DESCRIPTION="A simple library to embed Gecko (xulrunner) to the Mono Winforms
WebControl"
HOMEPAGE="http://mono-project.com/Gluezilla"
SRC_URI=""

LICENSE="LGPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND="dev-libs/nss
	dev-libs/nspr
	>=net-libs/xulrunner-1.8.1.17"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_compile() {
#	./autogen.sh ${buildopts} \
#	--host=${CHOST} \
#	--sysconfdir=/etc/ \
#	--prefix=/usr/ \
#	--infodir=/usr/share/info \
#	-mandir=/usr/share/man \
#	--enable-debug || die "./autogen.sh failed"
	econf || die "econf failed"
	emake || die "Make failed"
}

src_install () {
	emake DESTDIR=${D} install || die "install failed"
	dodoc AUTHORS ChangeLog README TODO || die "dodoc failed"
}
