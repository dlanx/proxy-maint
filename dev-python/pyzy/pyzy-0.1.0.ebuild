# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils autotools

PY_DATABASE=${PN}-database-1.0.0
DESCRIPTION="The Chinese PinYin and Bopomofo conversion library"
HOMEPAGE="https://github.com/pyzy"
SRC_URI="https://pyzy.googlecode.com/files/${P}.tar.gz
	https://pyzy.googlecode.com/files/${PY_DATABASE}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+boost +db doc +opencc"

RDEPEND="dev-libs/glib:2
	boost? ( dev-libs/boost )
	opencc? ( app-i18n/opencc )"

DEPEND="${DEPEND}
	doc? ( app-doc/doxygen )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-db.patch
	eautoreconf
}

src_configure() {
	econf \
		--datadir=/usr/share/ibus-pinyin \
		$(use_enable boost) \
		$(use_enable opencc) \
		$(use_enable db db-android)
}
