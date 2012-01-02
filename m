From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnetfilter_log 1.0.1 release
Date: Mon, 2 Jan 2012 21:26:41 +0100
Message-ID: <20120102202641.GA26980@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3MwIy2ne0vdjdPXF"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnetfilter_log 1.0.1

libnetfilter_log is a userspace library providing interface to packets
that have been logged by the kernel packet filter.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libnetfilter_log/downloads.html
ftp://ftp.netfilter.org/pub/libnetfilter_log/

Have fun!

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_log-1.0.1.txt"

Jan Engelhardt (23):
      build: use autoconf-suggested naming of files
      build: use modern call syntax for AC_INIT, AM_INIT_AUTOMAKE
      build: avoid use of deprecated INCLUDES
      build: use simpler autoreconf in autogen
      build: run AC_CANONICAL_HOST only
      build: remove statements without effect
      build: remove -fPIC flag
      build: no need for error message in PKG_CHECK_MODULES
      build: set Libs.private for pkgconfig file
      Remove accidentally-added file "depcomp"
      Add .gitignore files
      build: default to not building static libraries
      build: use AC_OUTPUT
      src: remove redundant casts
      src: declare non-modified data as const
      build: remove unused LIBTOOL_DEPS
      build: create a Make_global.am file
      build: use -Wall across the entire source
      utils: resolve compiler warnings
      build: fix error with automake-1.9
      Update .gitignore
      build: use AC_CONFIG_AUX_DIR and stash away tools
      build: disable implicit .tar.gz archive generation and use POSIX mode

Pablo Neira Ayuso (7):
      build: bump version to 1.0.0
      license: upgrade to GPLv2+
      doc: discourage the use of nflog_set_nlbufsiz()
      Merge branch 'master' of git://dev.medozas.de/libnetfilter_log
      build: fix `make distcheck'
      build: Linux kernel-style for compilation messages
      build: bump version to 1.0.1


--3MwIy2ne0vdjdPXF--
