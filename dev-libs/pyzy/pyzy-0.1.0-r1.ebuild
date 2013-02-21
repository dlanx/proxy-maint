# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils autotools

DESCRIPTION="the Chinese PinYin and Bopomofo conversion library"
HOMEPAGE="http://code.google.com/p/pyzy/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz
	http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-database-1.0.0.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND=">=dev-db/sqlite-3.6.18
	>=dev-libs/glib-2.24
	sys-apps/util-linux"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	>=sys-devel/gettext-0.16.1"

src_prepare() {
	# Using open-phrase database downloaded by this ebuild script.
	epatch "${FILESDIR}"/pyzy-dont-download-dictionary-file.patch

	mv ../db ./data/db/open-phrase/ || die
}

src_configure() {
	econf \
		--enable-db-open-phrase \
		--disable-db-android
}
