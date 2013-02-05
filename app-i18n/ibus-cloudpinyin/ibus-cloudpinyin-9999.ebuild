# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit vala subversion

DESCRIPTION="Cloud Pinyin for Ibus"
HOMEPAGE="http://code.google.com/p/ibus-cloud-pinyin/"
ESVN_REPO_URI="http://ibus-cloud-pinyin.googlecode.com/svn/trunk"

LICENSE=""
SLOT="0"
KEYWORDS=""
IUSE="+vala"

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	use vala && vala_src_prepare
}
