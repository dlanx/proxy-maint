# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/ofono/ofono-1.10.ebuild,v 1.2 2012/12/03 02:28:30 ssuominen Exp $

EAPI=5

AUTOTOOLS_AUTORECONF=1
AUTOTOOLS_IN_SOURCE_BUILD=1

EGIT_REPO_URI="git://git.kernel.org/pub/scm/network/${PN}/${PN}.git"
inherit eutils multilib autotools-utils systemd git-2

DESCRIPTION="Open Source mobile telephony (GSM/UMTS) daemon."
HOMEPAGE="http://ofono.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+atmodem bluetooth +cdmamodem +datafiles doc dundee examples +isimodem
+phonesim +provision +qmimodem threads test tools +udev"

REQUIRED_USE="dundee? ( bluetooth )"

RDEPEND=">=sys-apps/dbus-1.4
	>=dev-libs/glib-2.28
	net-misc/mobile-broadband-provider-info
	bluetooth? ( >=net-wireless/bluez-4.99 )
	udev? ( virtual/udev )
	examples? ( dev-python/dbus-python )
	tools? ( virtual/libusb:1 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS=( ChangeLog AUTHORS )

src_prepare() {
	autotools-utils_src_prepare
}

src_configure() {
	econf \
		$(use_enable threads) \
		$(use_enable udev) \
		$(use_enable isimodem) \
		$(use_enable atmodem) \
		$(use_enable cdmamodem) \
		$(use_enable datafiles) \
		$(use_enable dundee) \
		$(use_enable bluetooth) \
		$(use_enable phonesim) \
		$(use_enable provision) \
		$(use_enable qmimodem) \
		$(use_enable tools) \
		$(use_enable test) \
		--disable-maintainer-mode \
		--localstatedir=/var \
		--with-systemdunitdir="$(systemd_get_unitdir)"
}

src_install() {
	default

	if ! use examples ; then
		rm -rf "${D}/usr/$(get_libdir)/ofono/test" || die
	fi

	if use tools ; then
		dobin tools/{auto-enable,huawei-audio}
	fi

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	use doc && dodoc doc/*.txt
}
