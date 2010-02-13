# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs subversion

DESCRIPTION="Low Level Virtual Machine"
HOMEPAGE="http://llvm.org/"

ESVN_REPO_URI="http://llvm.org/svn/llvm-project/llvm/trunk"
ESVN_CO_DIR="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}"/svn-src/${P/-svn}/"${ESVN_REPO_URI##*/}"
ESVN_PROJECT="${P}"

# Not in portage; available as LICENSE.txt in the source tarball
LICENSE="UoI-NCSA"

SLOT="0"

KEYWORDS="~amd64 ~ppc ~x86"

IUSE="debug alltargets clang"
# 'jit' is not a flag anymore.  at least on x86, disabling it saves nothing
# at all, so having it always enabled for platforms that support it is fine

# we're not mirrored, fetch from homepage
RESTRICT="mirror"

# See http://www.llvm.org/docs/GettingStarted.html#brokengcc
# for explanations of blockers
DEPEND=">=dev-lang/perl-5.6
		>=sys-devel/make-3.79
		>=sys-devel/gcc-3.4
		!=sys-devel/gcc-4.1.1
		x86? ( !=sys-devel/gcc-3.4.0 !=sys-devel/gcc-3.4.2 )
		amd64? ( !=sys-devel/gcc-3.4.6 )
      "
RDEPEND="dev-lang/perl"
PDEPEND=""

S="${WORKDIR}/trunk"

pkg_setup() {
	if [ $(ld --version | head -n1 | cut -f5 -d" ") = "2.17" ]; then
		ewarn "The ld included in binutils-2.17 is known to perform poorly with llvm"
		ewarn "See http://www.llvm.org/docs/GettingStarted.html#brokengcc for info"
	fi
}

src_unpack() {
	subversion_fetch
	export LLVM_REV=$(svn up | sed 's/At revision //; s/\.//')

	if use clang; then
		if [ ! -e tools/clang ]; then
			svn co http://llvm.org/svn/llvm-project/cfe/trunk tools/clang
		else
			cd tools/clang
			svn up
			cd ../../
		fi

		if [ ! -e "${S}/tools/clang" ]; then
			cp -rf tools/clang "${S}/tools/"
		fi
	fi

	cd "${S}"

	# unfortunately ./configure won't listen to --mandir and the-like, so take
	# care of this.
	einfo "Fixing install dirs"
	sed -e 's,^PROJ_docsdir.*,PROJ_docsdir := $(DESTDIR)$(PROJ_prefix)/share/doc/'${PF}, \
		-e 's,^PROJ_etcdir.*,PROJ_etcdir := $(DESTDIR)/etc/llvm,' \
		-i Makefile.config.in || die "sed failed"

	# all binaries get rpath'd to a dir in the temporary tree that doesn't
	# contain libraries anyway; can safely remove those to avoid QA warnings
	# (the exception would be if we build shared libraries, which we don't)
	einfo "Fixing rpath"
	sed -e 's,-rpath \$(ToolDir),,g' -i Makefile.rules || die "sed failed"
}

src_compile() {
	local CONF_FLAGS=""

	if use debug; then
		CONF_FLAGS="${CONF_FLAGS} --disable-optimized"
		einfo "Note: Compiling LLVM in debug mode will create huge and slow binaries"
		# ...and you probably shouldn't use tmpfs, unless it can hold 900MB
	else
		CONF_FLAGS="${CONF_FLAGS} --enable-optimized --disable-assertions \
--disable-expensive-checks"
	fi
	
	if use alltargets; then
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=all"
	else
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=host-only"
	fi

	# a few minor things would be built a bit differently depending on whether
	# llvm-gcc is already present on the system or not.  let's avoid that by
	# not letting it find llvm-gcc.  llvm-gcc isn't required for anything
	# anyway.  this dummy path will get spread to a few places, but none where
	# it really matters.
	CONF_FLAGS="${CONF_FLAGS} --with-llvmgccdir=/dev/null"

	econf ${CONF_FLAGS} || die "econf failed"
	emake REQUIRES_RTTI=1 || die "emake failed"
}

src_install()
{
	make DESTDIR="${D}" install || die "make install failed"

	# for some reason, LLVM creates a few .dir files.  remove them
	find "${D}" -name .dir -print0 | xargs -r0 rm

	# tblgen and stkrc do not get installed and wouldn't be very useful anyway,
	# so remove their man pages.  llvmgcc.1 and llvmgxx.1 are present here for
	# unknown reasons.  llvm-gcc will install proper man pages for itself, so
	# remove them here
	einfo "Removing unnecessary man pages"
	rm "${D}"/usr/share/man/man1/{tblgen,stkrc,llvmgcc,llvmgxx}.1

	dodir "/etc/env.d"
	echo "LLVM_REV=${LLVM_REV}" > "${D}/etc/env.d/99llvm"
}


