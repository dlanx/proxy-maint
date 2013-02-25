# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /data/temp/gentoo//vcs-public-cvsroot/gentoo-x86/net-misc/directvnc/directvnc-0.7.6.ebuild,v 1.3 2012/05/05 03:20:44 jdhore Exp $

EAPI=5

AUTOTOOLS_IN_SOURCE_BUILD=1
AUTOTOOLS_AUTORECONF=1

EGIT_REPO_URI="git://github.com/drinkmilk/${PN}.git"
inherit eutils autotools-utils git-2

DESCRIPTION="Very thin VNC client for unix framebuffer systems"
HOMEPAGE="http://drinkmilk.github.com/directvnc/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+mouse dmalloc"

RDEPEND="dev-libs/DirectFB[fbcon,dynload]
	virtual/jpeg"

DEPEND="${RDEPEND}
	dmalloc? ( dev-libs/dmalloc )
	x11-proto/xproto"

DOCS=( NEWS THANKS )

src_prepare() {
	use mouse || epatch "${FILESDIR}"/${P}-mouse.patch

	autotools-utils_src_prepare
}

src_configure() {
	myeconfargs=(
		$(use_with dmalloc)
	)

	autotools-utils_src_configure
}

pkg_postinst() {
	einfo "To customize your keyboard mapping, please consult the manual"
	einfo " commmand: man 7 directvnc-kbmapping"
}
