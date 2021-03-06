# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

RESTRICT="primaryuri"

DESCRIPTION="last.fm scrobbler for everything."
HOMEPAGE="http://github.com/meh/LOLastfm"
SRC_URI="http://github.com/meh/LOLastfm/tarball/LOLastfm-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="minimal"

DEPEND="
!minimal? ( >=dev-lang/perl-5.8.1[ithreads] )
 minimal? ( dev-lang/perl )
"
RDEPEND="${DEPEND}"

src_unpack() {
	cd ${WORKDIR}
	tar xfv ${DISTDIR}/${P}
}

src_install() {
	cd ${WORKDIR}/$(ls)

	if use minimal; then
		mv bin/LOLastfm-minimal.pl LOLastfm
		dobin LOLastfm
	else
		mv bin/LOLastfm.pl LOLastfm
		dobin LOLastfm

		mv bin/LOLastfm-set.pl LOLastfm-set
		dobin LOLastfm-set
	fi

	exeinto /etc/init.d
	doexe etc/init.d/LOLastfm

	insinto /etc
	doins etc/LOLastfm.xml

	dodir /var/lib/LOLastfm/

	dodoc README || die

	ewarn "Remember to install from CPAN Net::LastFM::Submission and XML::Simple."
	ewarn ""
	ewarn "If you use MPD install Audio::MPD."
	ewarn "If you use Amarok install DCOP::Amarok::Player."
	ewarn "If you use an unsupported player emerge sys-process/lsof."
}
