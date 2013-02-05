# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

CMAKE_IN_SOURCE_BUILD=1

inherit cmake-utils

DESCRIPTION="wrapper libgooglepinyin for IBus"
HOMEPAGE="http://libgooglepinyin.googlecode.com/"
SRC_URI="http://libgooglepinyin.googlecode.com/files/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	app-i18n/libgooglepinyin
	>=app-i18n/ibus-1.4
	dev-lang/python"
DEPEND="${RDEPEND}
	dev-util/cmake"

S="${WORKDIR}/${PN}"

src_prepare(){
	epatch "${FILESDIR}/${PN}-pagesizepatch.patch"
	default
}
