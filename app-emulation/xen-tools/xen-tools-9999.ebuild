# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/xen-tools/xen-tools-9999.ebuild,v 1.7 2011/10/23 10:49:29 patrick Exp $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )
PYTHON_REQ_USE='xml,threads'

if [[ $PV == *9999 ]]; then
	KEYWORDS=""
	REPO="xen-unstable.hg"
	XEN_EXTFILES_URL="http://xenbits.xensource.com/xen-extfiles"
	IPXE_COMMIT="9a93db3f0947484e30e753bbd61a10b17336e20e"
	EGIT_REPO_URI="git://xenbits.xen.org/xen.git"
	EGIT_REPO_URI_QEMU="git://xenbits.xen.org/qemu-upstream-unstable.git"
	EGIT_REPO_URI_TRAD="git://xenbits.xen.org/qemu-xen-unstable.git"
	EGIT_REPO_URI_SEAB="git://xenbits.xen.org/seabios.git"
	SRC_URI="http://dev.gentoo.org/~alexxy/distfiles/ipxe-git-${IPXE_COMMIT}.tar.gz"
	S="${WORKDIR}/xen"
	live_eclass="git-2"
else
	KEYWORDS="~amd64 ~x86"
	XEN_EXTFILES_URL="http://xenbits.xensource.com/xen-extfiles"
	SRC_URI="http://bits.xensource.com/oss-xen/release/${PV}/xen-${PV}.tar.gz \
	$XEN_EXTFILES_URL/ipxe-git-v1.0.0.tar.gz"
	S="${WORKDIR}/xen-${PV}"
fi

inherit flag-o-matic eutils multilib python-single-r1 toolchain-funcs ${live_eclass}

DESCRIPTION="Xend daemon and tools"
HOMEPAGE="http://xen.org/"
DOCS=( README docs/README.xen-bugtool docs/ChangeLog )

LICENSE="GPL-2"
SLOT="0"
IUSE="api custom-cflags debug doc flask hvm qemu ocaml python pygrub screen static-libs xend"

REQUIRED_USE="hvm? ( qemu )"

CDEPEND="dev-libs/lzo:2
	dev-libs/yajl
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/pypam[${PYTHON_USEDEP}]
	dev-python/pyxml
	sys-libs/zlib
	sys-power/iasl
	dev-ml/findlib
	hvm? ( media-libs/libsdl )
	${PYTHON_DEPS}
	api? ( dev-libs/libxml2
		net-misc/curl )
	pygrub? ( ${PYTHON_DEPS//${PYTHON_REQ_USE}/ncurses} )"

DEPEND="${CDEPEND}
	sys-devel/bin86
	sys-devel/dev86
	dev-lang/perl
	app-misc/pax-utils
	doc? (
		app-doc/doxygen
		dev-tex/latex2html[png,gif]
		media-gfx/transfig
		media-gfx/graphviz
		dev-tex/xcolor
		dev-texlive/texlive-latexextra
		virtual/latex-base
		dev-tex/latexmk
		dev-texlive/texlive-latex
		dev-texlive/texlive-pictures
		dev-texlive/texlive-latexrecommended
	)
	hvm? ( x11-proto/xproto
		 !net-libs/libiscsi )
	 qemu? ( x11-libs/pixman )"

RDEPEND="${CDEPEND}
	sys-apps/iproute2
	net-misc/bridge-utils
	ocaml? ( >=dev-lang/ocaml-4 )
	screen? (
		app-misc/screen
		app-admin/logrotate
	)
	virtual/udev"

# hvmloader is used to bootstrap a fully virtualized kernel
# Approved by QA team in bug #144032
QA_WX_LOAD="usr/lib/xen/boot/hvmloader"


RESTRICT="test"

xen-tools_init_variables() {
	EGIT_REPO_URI="$1"
	EGIT_DEST="$2"
	EGIT_BRANCH="${3:-master}"
	EGIT_PROJECT="${EGIT_REPO_URI##*/}"
	EGIT_SOURCEDIR=${WORKDIR}/${EGIT_PROJECT%.git}
}

xen-tools_checkout() {
	# just create proper symbol link
	ln -s ${WORKDIR}/${EGIT_PROJECT%.git} ${S}/${EGIT_DEST} || die
}

xen-tools_cleanup() {
	unset EGIT_BRANCH
	unset EGIT_COMMIT
}

xen-tools_unpack() {
	xen-tools_init_variables $@

	git-2_init_variables
	git-2_prepare_storedir
	git-2_migrate_repository
	git-2_fetch
	git-2_gc
	git-2_submodules
	git-2_move_source
	git-2_branch

	xen-tools_checkout
	git-2_cleanup
	xen-tools_cleanup
}

pkg_setup() {
	python_single-r1_pkg_setup
	export "CONFIG_TESTS=n"

	if has_version dev-libs/libgcrypt; then
		export "CONFIG_GCRYPT=y"
	fi

	if use qemu; then
		export "CONFIG_IOEMU=y"
	else
		export "CONFIG_IOEMU=n"
	fi

	if ! use x86 && ! has x86 $(get_all_abis) && use hvm; then
		eerror "HVM (VT-x and AMD-v) cannot be built on this system. An x86 or"
		eerror "an amd64 multilib profile is required. Remove the hvm use flag"
		eerror "to build xen-tools on your current profile."
		die "USE=hvm is unsupported on this system."
	fi

	if [[ -z ${XEN_TARGET_ARCH} ]] ; then
		if use x86 && use amd64; then
			die "Confusion! Both x86 and amd64 are set in your use flags!"
		elif use x86; then
			export XEN_TARGET_ARCH="x86_32"
		elif use amd64 ; then
			export XEN_TARGET_ARCH="x86_64"
		else
			die "Unsupported architecture!"
		fi
	fi

	use api     && export "LIBXENAPI_BINDINGS=y"
	use flask   && export "FLASK_ENABLE=y"
}

src_unpack() {
	git-2_src_unpack
	xen-tools_unpack "${EGIT_REPO_URI_QEMU}" tools/qemu-xen-dir
	xen-tools_unpack "${EGIT_REPO_URI_TRAD}" tools/qemu-xen-traditional-dir
	xen-tools_unpack "${EGIT_REPO_URI_SEAB}" tools/firmware/seabios-dir 1.7.1-stable-xen
}

src_prepare() {
	cp "$DISTDIR/ipxe-git-${IPXE_COMMIT}.tar.gz" tools/firmware/etherboot/ipxe.tar.gz
	sed -e 's/-Wall//' -i Config.mk || die "Couldn't sanitize CFLAGS"

	# Drop .config
	sed -e '/-include $(XEN_ROOT)\/.config/d' -i Config.mk || die "Couldn't drop"
	# Xend
	if ! use xend; then
		sed -e 's:xm xen-bugtool xen-python-path xend:xen-bugtool xen-python-path:' \
			-i tools/misc/Makefile || die "Disabling xend failed" || die
		sed -e 's:^XEND_INITD:#XEND_INITD:' \
			-i tools/examples/Makefile || "Disabling xend failed" || die
	fi
	# if the user *really* wants to use their own custom-cflags, let them
	if use custom-cflags; then
		einfo "User wants their own CFLAGS - removing defaults"

	# try and remove all the default custom-cflags
	find "${S}" -name Makefile -o -name Rules.mk -o -name Config.mk -exec sed \
		-e 's/CFLAGS\(.*\)=\(.*\)-O3\(.*\)/CFLAGS\1=\2\3/' \
		-e 's/CFLAGS\(.*\)=\(.*\)-march=i686\(.*\)/CFLAGS\1=\2\3/' \
		-e 's/CFLAGS\(.*\)=\(.*\)-fomit-frame-pointer\(.*\)/CFLAGS\1=\2\3/' \
		-e 's/CFLAGS\(.*\)=\(.*\)-g3*\s\(.*\)/CFLAGS\1=\2 \3/' \
		-e 's/CFLAGS\(.*\)=\(.*\)-O2\(.*\)/CFLAGS\1=\2\3/' \
		-i {} \; || die "failed to re-set custom-cflags"
	fi

	if ! use pygrub; then
		sed -e '/^SUBDIRS-$(PYTHON_TOOLS) += pygrub$/d' -i tools/Makefile || die
	fi

	# Disable hvm support on systems that don't support x86_32 binaries.
	if ! use hvm; then
		chmod 644 tools/check/check_x11_devel
		sed -e '/^CONFIG_IOEMU := y$/d' -i config/*.mk || die
		sed -e '/SUBDIRS-$(CONFIG_X86) += firmware/d' -i tools/Makefile || die
	fi

	# Don't bother with qemu, only needed for fully virtualised guests
	if ! use qemu; then
		sed -e "/^CONFIG_IOEMU := y$/d" -i config/*.mk || die
		sed -e "s:install-tools\: tools/ioemu-dir:install-tools\: :g" -i Makefile || die
	fi

	# Fix build for gcc-4.6
	local WERROR=(
		"tools/libxl/Makefile"
		"tools/xenstat/xentop/Makefile"
		)
	for mf in ${WERROR[@]} ; do
		sed -e "s:-Werror::g" -i $mf || die
	done

	# Prevent the downloading of ipxe
	sed -e 's:^\tif ! wget -O _$T:#\tif ! wget -O _$T:' \
		-e 's:^\tfi:#\tfi:' -i \
		-e 's:^\tmv _$T $T:#\tmv _$T $T:' \
		-i tools/firmware/etherboot/Makefile || die
	epatch_user
}

src_configure() {
	econf \
		--enable-lomount \
		--disable-werror \
		BISON=/usr/bin/bison \
		FLEX=/usr/bin/flex

}

src_compile() {
	export VARTEXFONTS="${T}/fonts"
	local myopt
	use debug && myopt="${myopt} debug=y"

	use custom-cflags || unset CFLAGS
	if test-flag-CC -fno-strict-overflow; then
		append-flags -fno-strict-overflow
	fi

	unset LDFLAGS
	unset CFLAGS
	emake V=1 CC="$(tc-getCC)" LD="$(tc-getLD)" AR="$(tc-getAR)" RANLIB="$(tc-getRANLIB)" -C tools ${myopt}
	use doc && emake docs
	emake -C docs man-pages
}

src_install() {
	# Override auto-detection in the build system, bug #382573
	export INITD_DIR=/etc/init.d
	export CONFIG_LEAF_DIR=../tmp/default

	# Let the build system compile installed Python modules.
	local PYTHONDONTWRITEBYTECODE
	export PYTHONDONTWRITEBYTECODE

	emake DESTDIR="${D}" DOCDIR="/usr/share/doc/${PF}" \
		XEN_PYTHON_NATIVE_INSTALL=y install-tools

	# Fix the remaining Python shebangs.
	python_fix_shebangs "${D}"

	# Remove RedHat-specific stuff
	rm -rf "${D}"/etc/init.d/xen* "${D}"/etc/default || die

	# uncomment lines in xl.conf
	sed -e 's:^#autoballoon=1:autoballoon=1:' \
		-e 's:^#lockfile="/var/lock/xl":lockfile="/var/lock/xl":' \
		-e 's:^#vifscript="vif-bridge":vifscript="vif-bridge":' \
		-i tools/examples/xl.conf  || die

	if use doc; then
		emake DESTDIR="${D}" DOCDIR="/usr/share/doc/${PF}" install-docs

		docinto pdf
		dodoc ${DOCS[@]}
		[ -d "${D}"/usr/share/doc/xen ] && mv "${D}"/usr/share/doc/xen/* "${D}"/usr/share/doc/${PF}/html
	fi
	rm -rf "${D}"/usr/share/doc/xen/
	doman docs/man?/*

	if use xend; then
		newinitd "${FILESDIR}"/xend.initd-r2 xend
	fi
	newconfd "${FILESDIR}"/xendomains.confd xendomains
	newconfd "${FILESDIR}"/xenstored.confd xenstored
	newconfd "${FILESDIR}"/xenconsoled.confd xenconsoled
	newinitd "${FILESDIR}"/xendomains.initd-r2 xendomains
	newinitd "${FILESDIR}"/xenstored.initd xenstored
	newinitd "${FILESDIR}"/xenconsoled.initd xenconsoled

	if use screen; then
		cat "${FILESDIR}"/xendomains-screen.confd >> "${D}"/etc/conf.d/xendomains || die
		cp "${FILESDIR}"/xen-consoles.logrotate "${D}"/etc/xen/ || die
		keepdir /var/log/xen-consoles
	fi

	# Move files built with use qemu, Bug #477884
	if [[ "${ARCH}" == 'amd64' ]] && use qemu; then
		mkdir -p "${D}"usr/$(get_libdir)/xen/bin || die
		mv "${D}"usr/lib/xen/bin/* "${D}"usr/$(get_libdir)/xen/bin/ || die
	fi

	# For -static-libs wrt Bug 384355
	if ! use static-libs; then
		rm -f "${D}"usr/$(get_libdir)/*.a "${D}"usr/$(get_libdir)/ocaml/*/*.a
	fi

	# xend expects these to exist
	keepdir /var/run/xenstored /var/lib/xenstored /var/xen/dump /var/lib/xen /var/log/xen

	# for xendomains
	keepdir /etc/xen/auto

	# Temp QA workaround
	dodir "$(udev_get_udevdir)"
	mv "${D}"/etc/udev/* "${D}/$(udev_get_udevdir)"
	rm -rf "${D}"/etc/udev

	# Remove files failing QA AFTER emake installs them, avoiding seeking absent files
	find "${D}" \( -name openbios-sparc32 -o -name openbios-sparc64 \
		-o -name openbios-ppc -o -name palcode-clipper \) -delete || die
}

pkg_postinst() {
	elog "Official Xen Guide and the unoffical wiki page:"
	elog " http://www.gentoo.org/doc/en/xen-guide.xml"
	elog " http://gentoo-wiki.com/HOWTO_Xen_and_Gentoo"

	if [[ "$(scanelf -s __guard -q $(type -P python))" ]] ; then
		echo
		ewarn "xend may not work when python is built with stack smashing protection (ssp)."
		ewarn "If 'xm create' fails with '<ProtocolError for /RPC2: -1 >', see bug #141866"
		ewarn "This probablem may be resolved as of Xen 3.0.4, if not post in the bug."
	fi

	if ! has_version "dev-lang/python[ncurses]"; then
		echo
		ewarn "NB: Your dev-lang/python is built without USE=ncurses."
		ewarn "Please rebuild python with USE=ncurses to make use of xenmon.py."
	fi

	if has_version "sys-apps/iproute2[minimal]"; then
		echo
		ewarn "Your sys-apps/iproute2 is built with USE=minimal. Networking"
		ewarn "will not work until you rebuild iproute2 without USE=minimal."
	fi

	if ! use hvm; then
		echo
		elog "HVM (VT-x and AMD-V) support has been disabled. If you need hvm"
		elog "support enable the hvm use flag."
		elog "An x86 or amd64 multilib system is required to build HVM support."
		echo
		elog "The qemu use flag has been removed and replaced with hvm."
	fi

	if use xend; then
		echo
		elog "xend capability has been enabled and installed"
	fi

	if grep -qsF XENSV= "${ROOT}/etc/conf.d/xend"; then
		echo
		elog "xensv is broken upstream (Gentoo bug #142011)."
		elog "Please remove '${ROOT%/}/etc/conf.d/xend', as it is no longer needed."
	fi
}
