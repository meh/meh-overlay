# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
PYTHON_USE_WITH="xml threads"

inherit subversion distutils eutils

DESCRIPTION="The Closure Linter is a utility that checks JavaScript files for style issues such as operator placement, missing semicolons, spacing, the presence of JsDoc annotations, and more."
HOMEPAGE="http://code.google.com/closure/utilities/"
ESVN_REPO_URI="http://closure-linter.googlecode.com/svn/trunk/"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/python-gflags"
RDEPEND="${DEPEND}"

src_unpack() {
	subversion_src_unpack
}

src_install() {
	distutils_src_install
}
