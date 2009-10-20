# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit distutils eutils

DESCRIPTION="a Last.fm 'plugin' client implemented in Python."
SRC_URI="http://www.red-bean.com/~decklin/software/lastfmsubmitd/${P}.tar.gz"
HOMEPAGE="http://www.red-bean.com/~decklin/software/lastfmsubmitd/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ia64 ppc ppc64 sparc x86"
IUSE=""
RDEPEND=""


src_unpack () {
	unpack "${A}"
	cd "${S}"
	epatch ${FILESDIR}/${P}.patch
}


src_install() {
	distutils_src_install
	dodoc INSTALL

	# Now install rc-scripts
	doinitd ${FILESDIR}/init/lastfmsubmitd
#	doinitd ${FILESDIR}/init/lastmp

	# Directories at /var (spool, logs...)
	for x in log run spool ; do
		install -d ${D}/var/$x/lastfm
		fowners lastfm /var/$x/lastfm
		fperms 775 /var/$x/lastfm
		keepdir /var/$x/lastfm
	done
	touch ${D}/var/log/lastfm/lastfm.log
	fowners lastfm /var/log/lastfm/lastfm.log

	# Change ownership and make these setuid
	for x in lastcd lastmp ; do
		fowners lastfm /usr/bin/$x
		fperms u+s /usr/bin/$x
	done

	# Configuration files.
	insinto /etc
	doins ${FILESDIR}/lastfmsubmitd.conf
#	doins ${FILESDIR}/lastmp.conf
}


pkg_postinst () {
	einfo
	einfo "You must edit '/etc/lastfmsubmitd.conf' before use."
	einfo "To use with media-sound/moc you may need this script"
	einfo "http://files.lukeplant.fastmail.fm/public/moc_submit_lastfm"
	einfo
}


pkg_setup () {
	enewuser lastfm -1 "/bin/sh"
}

