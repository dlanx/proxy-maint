# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libev/libev-4.11.ebuild,v 1.2 2012/05/12 19:17:33 aballier Exp $

EAPI=5

ECVS_SERVER="anonymous@cvs.schmorp.de/schmorpforge"
ECVS_MODULE="libev"
inherit autotools cvs eutils multilib

MY_P="${P}"

DESCRIPTION="A high-performance event loop/event model with lots of feature"
HOMEPAGE="http://software.schmorp.de/pkg/libev.html"
SRC_URI=""

LICENSE="|| ( BSD GPL-2 )"
SLOT="0"
KEYWORDS=""
IUSE="elibc_glibc static-libs"

# Bug #283558
DEPEND="elibc_glibc? ( >=sys-libs/glibc-2.9_p20081201 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS=( Changes README )

src_prepare() {
	eautoreconf
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	use static-libs || prune_libtool_files
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libev.so.3.0.0
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libev.so.3.0.0
}
