# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils multilib toolchain-funcs versionator

DESCRIPTION="Google Chrome is a browser that combines a minimal design with sophisticated technology to make the web faster, safer, and easier."
HOMEPAGE="http://www.google.com/chrome"
MY_PN="${PN%-bin}-unstable_current"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="primaryuri" #fetch

DEPEND="app-arch/lzma-utils"
RDEPEND=">=sys-devel/gcc-4.2[-nocxx]
	|| ( media-fonts/liberation-fonts media-fonts/corefonts )
	x86? (
		dev-libs/atk
		x11-libs/cairo
		media-libs/fontconfig
		media-libs/freetype
		dev-libs/glib:2
		x11-libs/gtk+:2
		dev-libs/nspr
		dev-libs/nss
		x11-libs/pango
	)
	!x86? (
		app-emulation/emul-linux-x86-baselibs
		>=app-emulation/emul-linux-x86-gtklibs-20081109
		app-emulation/emul-linux-x86-soundlibs
		app-emulation/emul-linux-x86-xlibs
	)"
	#x11-misc/xdg-utils

CHROME_HOME="/opt/google/chrome"
QA_EXECSTACK="${CHROME_HOME}/chrome"

pkg_nofetch() {
	elog "Please download"
	for i in ${A}; do
		[[ ${i} = ${MY_PN}_* ]] && elog "${SRC_BASE}${i}"
	done
	elog "and save to ${DISTDIR}"
}

src_unpack() {
	elog "Installing/updating to current version"
	AR="google-chrome-unstable_current.deb"
	if use x86; then
		wget -c	"http://dl.google.com/linux/direct/google-chrome-unstable_current_i386.deb"	-O "${T}"/"${AR}"
	else	
		wget -c	"http://dl.google.com/linux/direct/google-chrome-unstable_current_amd64.deb" -O "${T}"/"${AR}"
	fi
	
	ar x "${T}"/"${AR}"
	if [[ ${AR} = *.deb ]]; then
		if [[ -e ${WORKDIR}/data.tar.lzma ]]; then
			mv ${WORKDIR}/data.tar.lzma ${WORKDIR}/${MY_PN}.tar.lzma
		elif [[ -e ${WORKDIR}/data.tar.gz ]]; then
			mv ${WORKDIR}/data.tar.gz ${WORKDIR}/${MY_PN}.tar.gz
		else
			die "Can't find data from ${AR}"
		fi
	fi
}

src_install() {
	cd ${D}
	lzma -cd ${WORKDIR}/${MY_PN}.tar.lzma | tar xvf - || die "Couldn't extract"
	rm -r etc
	dosym ../../..${CHROME_HOME}/${PN%-bin}.desktop \
		/usr/share/applications/${PN%-bin}.desktop
	if use x86; then
		mkdir -p ${D}${CHROME_HOME}/lib32
		for i in nss/lib{nss{,util},smime,ssl}3.so.1d \
		         nspr/lib{pl{ds,c},nspr}4.so.0d; do
			dosym ../../../../usr/$(get_libdir)/${i%.*} \
				${CHROME_HOME}/lib32/${i##*/}
		done
	else
		mkdir -p ${WORKDIR}/usr ${D}${CHROME_HOME}/lib32
		ln -fns ${D}${CHROME_HOME}/lib32 ${WORKDIR}/usr/lib
		for i in libgconf2-4 liborbit2; do
			gzip -cd ${WORKDIR}/${i}.tar.gz | (
				cd ${WORKDIR} && tar xvf - ./usr/lib/
			) || die "Couldn't extract ${i}"
		done
	fi
}

pkg_postinst() {
	elog "This Chrome binary package is from the developer preview channel.  It is"
	elog "not guaranteed to be stable or even usable."
	elog ""
	elog "Chrome's auto-update mechanism is only available for Debian-based"
	elog "distributions, and has been disabled."
	elog ""
	elog "Please see"
	elog "    http://dev.chromium.org/for-testers/bug-reporting-guidlines-for-the-mac-linux-builds"
	elog "before filing any bugs."
	use x86 || multilib_toolchain_setup x86
	if ! version_is_at_least 4.2 "$(gcc-version)" || [[ -z $(tc-getCXX) ]]; then
		einfo ""
		ewarn "This Chrome binary package depends on C++ libraries from >=sys-devel/gcc-4.2,"
		ewarn "which do not appear to be available.  Google Chrome may not run."
		ebeep
	fi
}
