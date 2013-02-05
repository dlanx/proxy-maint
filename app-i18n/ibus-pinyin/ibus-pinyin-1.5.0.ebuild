# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /data/temp/gentoo//vcs-public-cvsroot/gentoo-x86/app-i18n/ibus-pinyin/ibus-pinyin-1.4.0.ebuild,v 1.2 2012/05/03 19:24:26 jdhore Exp $

EAPI=4

PYTHON_DEPEND="2:2.5"
PYTHON_USE_WITH="sqlite"

inherit python

DESCRIPTION="Chinese PinYin IMEngine for IBus Framework"
HOMEPAGE="http://code.google.com/p/ibus/"
SRC_URI="http://ibus.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="boost lua nls"

RDEPEND=">=app-i18n/ibus-1.4
	sys-apps/util-linux
	boost? ( >=dev-libs/boost-1.39 )
	lua? ( >=dev-lang/lua-5.1 )
	nls? ( virtual/libintl )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	dev-python/pyzy
	nls? ( >=sys-devel/gettext-0.16.1 )"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	>py-compile
}

src_configure() {
	econf \
		$(use_enable boost) \
		$(use_enable lua lua-extension) \
		$(use_enable nls) \
		--enable-english-input-mode
}

pkg_postinst() {
	python_mod_optimize /usr/share/${PN}
}

pkg_postrm() {
	python_mod_cleanup /usr/share/${PN}
}
