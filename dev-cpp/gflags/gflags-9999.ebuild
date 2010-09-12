# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/gflags/gflags-1.2.ebuild,v 1.2 2010/05/29 20:50:21 arfrever Exp $

EAPI="3"

inherit subversion

DESCRIPTION="Google's C++ argument parsing library with python extensions."
HOMEPAGE="http://code.google.com/p/google-gflags/"
ESVN_REPO_URI="http://google-gflags.googlecode.com/svn/trunk/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND=""

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	./autogen.sh
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	rm -rf "${D}"/usr/share/doc/*
	AUTHORS ChangeLog NEWS README
	dohtml doc/*
}
