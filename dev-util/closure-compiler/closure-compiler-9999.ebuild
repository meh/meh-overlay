# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

JAVA_PKG_IUSE="doc source"
inherit subversion java-pkg-2 java-ant-2

DESCRIPTION="Closure Compiler is a JavaScript optimizing compiler."
HOMEPAGE="http://code.google.com/p/closure-compiler/"
ESVN_REPO_URI="http://closure-compiler.googlecode.com/svn/trunk/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

src_unpack() {
	subversion_src_unpack
}

src_install() {
	java-pkg_newjar build/compiler.jar closure-compiler.jar

	java-pkg_dolauncher closure-compiler --jar closure-compiler.jar
}
