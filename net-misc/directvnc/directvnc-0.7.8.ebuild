# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /data/temp/gentoo//vcs-public-cvsroot/gentoo-x86/net-misc/directvnc/directvnc-0.7.6.ebuild,v 1.3 2012/05/05 03:20:44 jdhore Exp $

EAPI=5

AUTOTOOLS_AUTORECONF=1

inherit eutils autotools-utils

DESCRIPTION="Very thin VNC client for unix framebuffer systems"
HOMEPAGE="http://drinkmilk.github.com/directvnc/"
SRC_URI="http://github.com/downloads/drinkmilk/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+mouse"

RDEPEND="dev-libs/DirectFB[fbcon]
	virtual/jpeg"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	>=sys-apps/sed-4
	x11-proto/xproto"

src_prepare() {
	use mouse || epatch "${FILESDIR}"/${P}-mouse.patch
	autotools-utils_src_prepare
}

src_install() {
	autotools-utils_src_install
	# default install goes to /usr/share/doc/${PN}, make it to ${P}
	rm -rf "${D}/usr/share/doc"
	dodoc AUTHORS changelog NEWS README THANKS
}
