# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

CMAKE_IN_SOURCE_BUILD=1

inherit multilib cmake-utils

HOMEPAGE="http://libgooglepinyin.googlecode.com/"
SRC_URI="http://libgooglepinyin.googlecode.com/files/${P}.tar.bz2"

DESCRIPTION="A fork from google pinyin on android "

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-util/cmake"
RDEPEND=""

src_configure() {
	local mycmakeargs="
		-DLIB_INSTALL_DIR=/usr/$(get_libdir)"

	cmake-utils_src_configure
}
