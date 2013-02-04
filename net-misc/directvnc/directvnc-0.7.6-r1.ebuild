# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /data/temp/gentoo//vcs-public-cvsroot/gentoo-x86/net-misc/directvnc/directvnc-0.7.6.ebuild,v 1.3 2012/05/05 03:20:44 jdhore Exp $

EAPI=5

inherit eutils

DESCRIPTION="Very thin VNC client for unix framebuffer systems"
HOMEPAGE="http://drinkmilk.github.com/directvnc/"
SRC_URI="http://github.com/downloads/drinkmilk/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE="+mouse"

RDEPEND="dev-libs/DirectFB[fbcon]
	virtual/jpeg"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	>=sys-apps/sed-4
	x11-proto/xproto"

src_prepare() {
	# Make mouse support optional
	use mouse || epatch "${FILESDIR}/${P}-mouse.patch"
}

src_install() {
	make install DESTDIR="${D}"
	rm -rf "${D}/usr/share/doc"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
