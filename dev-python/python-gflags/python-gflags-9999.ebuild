# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit distutils subversion

DESCRIPTION="Python equivalent of gflags."
HOMEPAGE="http://code.google.com/p/python-gflags/"
ESVN_REPO_URI="http://python-gflags.googlecode.com/svn/trunk/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-cpp/gflags-9999"
RDEPEND="${DEPEND}"

src_unpack() {
	subversion_src_unpack
}

src_install() {
	distutils_src_install
}
