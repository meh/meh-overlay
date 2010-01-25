# Copyright 2009 Blawl 
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Just a cool p2p vpn wrote for teh lulz"
HOMEPAGE="http://blawl.ath.cx/#project&id=lulznet"
SRC_URI="http://github.com/blawl/lulzNet/tarball/lulznet-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-libs/openssl 
		sys-libs/readline
		dev-libs/libxml2"
RDEPEND="${DEPEND}"

src_unpack() {
	cd ${WORKDIR}
	tar xfv ${DISTDIR}/${P}
}

src_compile() {
	cd ${WORKDIR}/$(ls)

	econf
	emake || die "emake fail'd" 
}

src_install() {
	cd ${WORKDIR}/$(ls)

	emake DESTDIR="${D}" install || die "install fail'd"
}
