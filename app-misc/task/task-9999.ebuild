# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/task/task-1.9.3-r1.ebuild,v 1.1 2010/11/20 22:24:17 radhermit Exp $

EAPI=3

EGIT_BRANCH="1.9.4"

inherit eutils cmake-utils git

DESCRIPTION="A task management tool with a command-line interface"
HOMEPAGE="http://taskwarrior.org/projects/show/taskwarrior/"
EGIT_REPO_URI="git://tasktools.org/task.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion debug lua +ncurses vim-syntax zsh-completion"

DEPEND="lua? ( dev-lang/lua )
	ncurses? ( sys-libs/ncurses )"
RDEPEND="${DEPEND}"

src_prepare() {
	# Use the correct directory locations
	sed -i -e "s:/usr/local/share/doc/task/rc:/usr/share/task/rc:" src/Config.cpp \
		doc/man/taskrc.5.in doc/man/task-tutorial.5.in doc/man/task-color.5.in || die "sed failed"

	sed -i -e "s:/usr/local/bin:/usr/bin:" doc/man/task-faq.5.in || die "sed failed"
}

src_configure() {
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_want lua LUA)
		$(cmake-utils_use_want ncurses NCURSES)
	"

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install DESTDIR="${D}" rcfiledir="/usr/share/task/rc" i18ndir="/usr/share/task" \
		bashscriptsdir="" vimscriptsdir="" zshscriptsdir="" \
		 || die "emake install failed"

	insinto /usr/share/task
	doins -r "${D}/usr/share/doc/task/rc"
	doins -r "${D}/usr/share/doc/task/i18n"
	doins -r "${D}/usr/share/doc/task/scripts"

	if use bash-completion ; then
		insinto /usr/share/bash-completion
		doins scripts/bash/*
	fi

	if use vim-syntax ; then
		rm scripts/vim/README
		insinto /usr/share/vim/vimfiles
		doins -r scripts/vim/*
	fi

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		doins scripts/zsh/*
	fi
}
