# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/mozilla-firefox/mozilla-firefox-3.0.1.ebuild,v 1.7 2008/09/03 08:47:51 armin76 Exp $

EAPI="2"
WANT_AUTOCONF="2.1"

inherit mercurial flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib fdo-mime autotools mozextension

# LANGS="be ca cs de eo en-US es-AR es-ES eu fi fr fy-NL ga-IE he hi-IN hu id it ja ko lt nb-NO nl nn-NO pa-IN pl pt-BR pt-PT ro ru si sk sv-SE uk zh-CN zh-TW"
# NOSHORTLANGS="es-AR pt-BR zh-CN"

MY_PV="${PV/3/}"

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="http://www.mozilla.com/firefox"

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="+alsa bindist java libnotify +networkmanager"

EHG_REPO_URI="http://hg.mozilla.org/mozilla-central"
EHG_PROJECT=mozilla-central

RDEPEND="
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.4
	>=dev-libs/nspr-4.8
	>=app-text/hunspell-1.2
	>=dev-db/sqlite-3.6.20-r1[fts3]
	alsa? ( media-libs/alsa-lib )
	>=x11-libs/cairo-1.8.8[X]
	x11-libs/pango[X]
	networkmanager? ( net-wireless/wireless-tools )
	libnotify? ( >=x11-libs/libnotify-0.4 )
	~net-libs/xulrunner-9999[java=,networkmanager=,libnotify=]"

DEPEND="${RDEPEND}
	java? ( >=virtual/jdk-1.4 )
	dev-util/pkgconfig"

RDEPEND="${RDEPEND} java? ( >=virtual/jre-1.4 )"

S="${WORKDIR}/mozilla-central"

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export MOZ_CO_PROJECT=browser
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1

pkg_setup(){
	if ! built_with_use x11-libs/cairo X; then
		eerror "Cairo is not built with X useflag."
		eerror "Please add 'X' to your USE flags, and re-emerge cairo."
		die "Cairo needs X"
	fi

	if ! built_with_use --missing true x11-libs/pango X; then
		eerror "Pango is not built with X useflag."
		eerror "Please add 'X' to your USE flags, and re-emerge pango."
		die "Pango needs X"
	fi

	if ! use bindist; then
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation"
		elog "You can disable it by emerging ${PN} _with_ the bindist USE-flag"

	fi
}

src_unpack() {
	mercurial_src_unpack

	export MAJ_PV=$(tail -n 1 "${S}/config/milestone.txt")
	export FIR_VERSION=$(cat "${S}/browser/config/version.txt")
}

src_prepare() {
	# Apply our patches
	cd "${S}" || die "cd failed"
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \

	eautoreconf
}

src_configure() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
	MEXTENSIONS="default"

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	use alpha && append-ldflags "-Wl,--no-relax"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --enable-application=browser
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate 'broken' --disable-crashreporter
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate 'gtk' --enable-default-toolkit=cairo-gtk2
	# Bug 60668: Galeon doesn't build without oji enabled, so enable it
	# regardless of java setting.
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places
	mozconfig_annotate '' --enable-safe-browsing

	# Build mozdevelop permately
	mozconfig_annotate ''  --enable-jsd --enable-xpctools

	# System-wide install specs
	mozconfig_annotate '' --disable-installer
	mozconfig_annotate '' --disable-updater
	mozconfig_annotate '' --disable-strip
	mozconfig_annotate '' --disable-install-strip

	# Use system libraries
	mozconfig_annotate '' --enable-system-cairo
	mozconfig_annotate '' --enable-system-hunspell
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss
	mozconfig_annotate '' --enable-system-lcms
	mozconfig_annotate '' --with-system-bz2
	mozconfig_annotate '' --with-system-libxul
	mozconfig_annotate '' -with-libxul-sdk=/usr/$(get_libdir)/xulrunner-devel-${MAJ_PV}

	mozconfig_use_enable libnotify
	mozconfig_use_enable java javaxpcom
	mozconfig_use_enable networkmanager necko-wifi
	mozconfig_use_enable alsa ogg
	mozconfig_use_enable alsa wave

	# Other ff-specific settings
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}

	# Enable/Disable audio in firefox
	mozconfig_use_enable alsa ogg
	mozconfig_use_enable alsa wave


	if ! use bindist; then
		mozconfig_annotate '' --enable-official-branding
	fi

	# Finalize and report settings
	mozconfig_final

	# -fstack-protector breaks us
	if gcc-version ge 4 1; then
		gcc-specs-ssp && append-flags -fno-stack-protector
	else
		gcc-specs-ssp && append-flags -fno-stack-protector-all
	fi
	filter-flags -fstack-protector -fstack-protector-all

	####################################
	#
	#  Configure and build
	#
	####################################

	CPPFLAGS="${CPPFLAGS} -DARON_WAS_HERE" \
	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	econf || die
}

src_compile() {
	# Should the build use multiprocessing? Not enabled by default, as it tends to break
	[ "${WANT_MP}" = "true" ] && jobs=${MAKEOPTS} || jobs="-j1"
	emake ${jobs} || die
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	emake DESTDIR="${D}" install || die "emake install failed"
	rm "${D}"/usr/bin/firefox

	cp "${FILESDIR}"/gentoo-default-prefs.js "${D}"${MOZILLA_FIVE_HOME}/defaults/${prefs}/all-gentoo.js

	# Install icon and .desktop for menu entry
	if ! use bindist; then
		newicon "${S}"/other-licenses/branding/firefox/content/icon48.png firefox-icon.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5.desktop \
			mozilla-firefox-3.0.desktop
	else
		newicon "${S}"/browser/base/branding/icon48.png firefox-icon-unbranded.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5-unbranded.desktop \
			mozilla-firefox-3.0.desktop
		sed -i -e "s/Bon Echo/Minefield/" "${D}"/usr/share/applications/mozilla-firefox-3.0.desktop
	fi

	# Create /usr/bin/firefox
	cat <<EOF >"${D}"/usr/bin/firefox
#!/bin/sh
export LD_LIBRARY_PATH="/usr/$(get_libdir)/xulrunner-${MAJ_PV}"
exec "/usr/$(get_libdir)/firefox-${FIR_VERSION}"/firefox "\$@"
EOF
	fperms 0755 /usr/bin/firefox

	dosym /usr/$(get_libdir)/xulrunner-${MAJ_PV}/defaults/autoconfig \
		${MOZILLA_FIVE_HOME}/defaults/autoconfig
}

pkg_postinst() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	ewarn "All the packages built against ${PN} won't compile,"
	ewarn "if after installing firefox 3.0 you get some blockers,"
	ewarn "please add 'xulrunner' to your USE-flags."

	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update
}
