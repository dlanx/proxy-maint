# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

AUTOTOOLS_AUTORECONF=1

inherit eutils git-2 autotools

DESCRIPTION="The Chinese PinYin and Bopomofo conversion library"
HOMEPAGE="https://github.com/pyzy"
EGIT_REPO_URI="git://github.com/pyzy/pyzy.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="+boost +db doc +opencc"

RDEPEND="dev-libs/glib:2
	boost? ( dev-libs/boost )
	opencc? ( app-i18n/opencc )"

DEPEND="${DEPEND}
	doc? ( app-doc/doxygen )"

src_configure() {
	econf \
		$(use_enable boost) \
		$(use_enable opencc) \
		$(use_enable db db-android)
}
