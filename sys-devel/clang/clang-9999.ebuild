# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="http://llvm.org/svn/llvm-project/llvm/trunk"

inherit subversion

DESCRIPTION="Clang C/C++ compiler"
HOMEPAGE="http://clang.llvm.org/"
SRC_URI=""

# See http://www.opensource.org/licenses/UoI-NCSA.php
LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND="dev-util/subversion"

S="${WORKDIR}/llvm"

src_unpack() {
	subversion_fetch     || die "${ESVN}: unknown problem occurred in subversion_fetch."
	subversion_bootstrap || die "${ESVN}: unknown problem occurred in subversion_bootstrap."
	
	cd "${S}/tools"
	
	# TODO: it'd probably be better to use subversion_fetch from subversion.eclass here
	einfo "Checking out Clang source..."
	svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
}

src_compile() {
	cd "${S}"
	econf --enable-optimized
	emake || die "emake failed"
}

src_install() {
	cd "${S}/tools/clang"
	emake DESTDIR="${D}" install || die "emake install failed"
}
