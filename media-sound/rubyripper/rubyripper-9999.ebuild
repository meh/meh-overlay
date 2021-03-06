# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/rubyripper/rubyripper-0.6.0.ebuild,v 1.1 2010/07/09 19:06:56 billie Exp $

EAPI=3

VIRTUALX_REQUIRED=always
USE_RUBY=ruby19

inherit git ruby-ng virtualx

DESCRIPTION="A secure audio ripper for Linux"
HOMEPAGE="http://code.google.com/p/rubyripper"
EGIT_REPO_URI="http://github.com/rubyripperdev/rubyripper.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~sparc ~x86"
IUSE="cli cdrdao flac +gtk +mp3 normalize +vorbis wav"

ILINGUAS="bg de es fr hu it nl ru se"

for lingua in $ILINGUAS; do
	IUSE="${IUSE} linguas_${lingua}"
done

RDEPEND="virtual/eject
	media-sound/cd-discid
	media-sound/cdparanoia
	cdrdao? ( app-cdr/cdrdao )
	flac? ( media-libs/flac )
	mp3? ( media-sound/lame )
	vorbis? ( media-sound/vorbis-tools )
	normalize? ( media-sound/normalize
		mp3? ( media-sound/mp3gain )
		vorbis? ( media-sound/vorbisgain )
		wav? ( media-sound/wavegain ) )"
DEPEND="${RDEPEND}"

ruby_add_rdepend ">=dev-ruby/ruby-gettext-2.1.0-r1
	>=dev-ruby/rcairo-1.8.1[svg]
	gtk? ( >=dev-ruby/ruby-gtk2-0.19.3 )"

# fix for bug 203737
RUBY_PATCHES=( "${FILESDIR}/${PN}-0.5.2-require-rubygems.patch" )

each_ruby_configure() {
	local myconf=--prefix=/usr
	local enable_linguas

	for lingua in $ILINGUAS; do
		use linguas_$lingua && enable_linguas="${enable_linguas},${lingua}"
	done

	[[ -n ${enable_linguas} ]] && myconf="${myconf} --enable-lang=${enable_linguas#,}"

	use gtk && myconf="${myconf} --enable-gtk2"
	use cli && myconf="${myconf} --enable-cli"

	# Force virtualmake to use configure instead of econf
	maketype=./configure
	virtualmake ${myconf}
}

each_ruby_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
