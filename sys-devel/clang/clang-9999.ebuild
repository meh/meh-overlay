# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

DESCRIPTION="C language family frontend for LLVM"
HOMEPAGE="http://clang.llvm.org/"
SRC_URI=""

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="alltargets"

DEPEND="=sys-devel/llvm-9999[clang]
	alltargets? ( =sys-devel/llvm-9999[clang,alltargets] )	
"
RDEPEND="${DEPEND}"
