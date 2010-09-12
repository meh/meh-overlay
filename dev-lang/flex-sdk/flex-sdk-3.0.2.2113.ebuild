# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
WANT_ANT_TASKS="ant-nodeps ant-contrib"

inherit subversion eutils java-pkg-2 java-ant-2 nsplugins

DESCRIPTION="Adobe's open source rich internet application framework."
HOMEPAGE="http://opensource.adobe.com/wiki/display/flexsdk/flex+sdk"

# binary package
#SRC_URI="http://flexorg.wip3.adobe.com/${PN//-/}/${PV}/${P//-/_}_mpl.zip"

ESVN_REPO_URI="http://opensource.adobe.com/svn/opensource/flex/sdk/tags/${PV}"

BLAZEDS_VERSION="3.0.1"
BLAZEDS_REPO_URI="http://opensource.adobe.com/svn/opensource/blazeds/tags/${BLAZEDS_VERSION}"

LICENSE="Mozilla"
SLOT="3"
KEYWORDS="~x86"
IUSE="astro doc samples source player nsplugin +adobe_xerces +adobe_fontengine"

RESTRICT="strip mirror"

CDEPEND="
	dev-java/bcel
	dev-java/commons-collections
	dev-java/commons-discovery
	dev-java/commons-logging
	dev-java/javacc
	dev-java/jflex
	dev-java/xalan
	!adobe_xerces? ( >=dev-java/xerces-2 )
	"

DEPEND=">=virtual/jdk-1.5
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
	nsplugin? ( !net-www/netscape-flash )
	${CDEPEND}"


EANT_DOC_TARGET=
EANT_EXTRA_ARGS="
	-Drelease=\"Flex ${SLOT}\"
	-Drelease.version=${PV%.*}
	-Dbuild.number=${PV##*.}"

src_unpack() {

	subversion_src_unpack

	(
		# this module is required from blazeds
		BLAZEDS_SUBPATH="modules/common"

		export ESVN_PROJECT="blazeds/${BLAZEDS_REPO_URI##*/}/${BLAZEDS_SUBPATH%/*}"
		export S="${S}/${BLAZEDS_SUBPATH}"
		export ESVN_REPO_URI="${BLAZEDS_REPO_URI}/${BLAZEDS_SUBPATH}"
		subversion_src_unpack
	)

	cd "${S}/lib"

	ADOBE_JARS="license.jar"

	# custom batik and velocity are open in trunk (4.0) but not in 3.0.*
	ADOBE_JARS="$(echo batik*.jar) ${ADOBE_JARS}"
	ADOBE_JARS="mm-velocity-1.4.jar ${ADOBE_JARS}"

	# adobe hasn't open sourced their changes to xerces?
	if use adobe_xerces; then
		ADOBE_JARS="xercesImpl.jar
					xercesImpl_ja.jar
					xercesPatch.jar
					xmlParserAPIs.jar
					${ADOBE_JARS}"
	else
		ewarn Line number support for XML tag attributes is not available without
		ewarn USE=adobe_xerces. It is possible that compile-time MXML error
		ewarn reporting and component debugging may not give correct line numbers.
	fi

	# AFEFontManager is not open source but optional
	if use adobe_fontengine; then
		ADOBE_JARS="
			flex-fontkit.jar
			afe.jar
			aglj32.jar
			rideau.jar
			${ADOBE_JARS}"
	fi

	for jar in ${ADOBE_JARS}; do
		mv "$jar" .. || die "failed to backup adobe's $jar"
	done

	rm * || die

	java-pkg_jarfrom commons-collections
	java-pkg_jarfrom commons-discovery
	java-pkg_jarfrom commons-logging
	java-pkg_jarfrom javacc
	java-pkg_jarfrom xalan

	if ! use adobe_xerces; then
		java-pkg_jarfrom xerces-2
	fi

	for jar in ${ADOBE_JARS}; do
		mv "../$jar" . || die "failed to restore adobe's $jar"
	done

	# antTasks has no classpath set
	java-ant_rewrite-classpath "${S}/modules/antTasks/build.xml"

	# trimmed down ASC source is bundled from tamarin
	cd "${S}/modules/asc/build/java/lib"
	rm * || die
	java-pkg_jarfrom bcel

	# linux wrapper scripts for abcdump, ash, swfdump are not provided
	for unprovided in ash abcdump swfdump; do
		sed s.lib/asc.lib/${unprovided}. "${S}/bin/asc" > "${S}/bin/${unprovided}"
		chmod 755 "${S}/bin/${unprovided}"
	done

	# release bug: avmplus is not set executable
	cp "${S}/modules/compiler/asdoc/avmplus.linux" "${S}/bin/avmplus"
	chmod 755 "${S}/bin/avmplus"

	# patch config for astro
	if use astro; then
		sed -i 's/\/9/\/{targetPlayerMajorVersion}/' \
			"${S}/frameworks/flex-config.xml" || die "failed to astroify"
	fi

	# unpack runtimes if needed
	if use astro; then
		RUNTIME_PATH="${S}/in/player/10/lnx"
	else
		RUNTIME_PATH="${S}/in/player/lnx"
	fi
	if use player; then
		cd "${S}/bin"
		DISTDIR="${RUNTIME_PATH}" unpack flashplayer.tar.gz || die failed to unpack player
	fi
	if use nsplugin; then
		cd "${S}/in"
		DISTDIR="${RUNTIME_PATH}" unpack libflashplayer.so.tar.gz || die failed to unpack plugin
	fi

	if use doc; then
		cd "${WORKDIR}"
		unpack ${A}
	fi
}

src_compile() {

	einfo Building slimmed-down ASC

	EANT_BUILD_XML="${S}/modules/asc/build/java/build.xml"
	java-pkg-2_src_compile || die "failed to build actionscript compiler"
	cp "${S}/modules/asc/lib/"*.jar "${S}/lib/" || die "failed to move asc jars"

	einfo Building common messaging components from BlazeDS

	EANT_BUILD_XML="${S}/modules/common/build.xml"
	java-pkg-2_src_compile || die "failed to build blazeds components"

	einfo Building antTasks

	EANT_GENTOO_CLASSPATH="ant-core"
	EANT_BUILD_XML="${S}/modules/antTasks/build.xml"
	java-pkg-2_src_compile || die "failed to build ant tasks"

	einfo Building Flex SDK

	EANT_BUILD_XML="${S}/build.xml"
	EANT_BUILD_TARGET="main"
	java-pkg-2_src_compile || die "failed to build flex sdk"

}


src_install() {
	dodoc README.txt
	dohtml collateral/en_US/*
	dodoc modules/compiler/flex_compiler_api_guide.pdf

	rm bin/*.exe bin/*.bat bin/adl

	if ! use source; then
		rm -rf frameworks/projects
	fi
	rm -rf frameworks/projects/*/asdoc
	rm -rf frameworks/tests

	INSTALL="flex-sdk-description.xml bin lib frameworks asdoc"

	if use samples; then
		INSTALL="${INSTALL} samples"
	fi

	FLEX_HOME=/usr/lib/${PN}-${SLOT}
	dodir ${FLEX_HOME}
	cp -pPr ${INSTALL} "${D}/${FLEX_HOME}/" || die "failed to install sdk"

	envfile=50${PN}
	# echo "FLEX_HOME=\"${FLEX_HOME}\"" >> ${envfile}
	echo "PATH=\"${FLEX_HOME}/bin\"" >> ${envfile}
	doenvd ${envfile}

	if use doc; then
		docinto html/langref
		dohtml -r "${WORKDIR}/flex3_documentation/langref/"
		rm -rf "${WORKDIR}/flex3_documentation/langref"
		docinto ""
		dodoc "${WORKDIR}/flex3_documentation/"*
		if use astro; then
			docinto html/astro
			dohtml -r "${WORKDIR}/astro_langRefStandalone/"
		fi
	fi

	if use nsplugin; then
		exeinto /opt/netscape/plugins
		doexe in/libflashplayer.so
		inst_plugin /opt/netscape/plugins/libflashplayer.so || die "failed to install plugin"
	fi
}

pkg_postinst() {
	if use astro; then
		einfo "Compile with -target-player=10.0.0 to target Flash Player 10."
	fi
	einfo "Please source /etc/profile in open shells before using flex."
}
