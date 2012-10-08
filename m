From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnfnetlink 1.0.1 release
Date: Mon, 8 Oct 2012 11:04:53 +0200
Message-ID: <20121008090453.GA14619@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="u3/rZRmxL6MmkK24"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net?
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnfnetlink 1.0.1

This release contains minor fixes and updates for this library.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libnfnetlink/downloads.html
ftp://ftp.netfilter.org/pub/libnfnetlink/

Have fun!

--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnfnetlink-1.0.1.txt"

Jan Engelhardt (22):
      build: use autoconf-suggested naming of files
      build: use modern call syntax for AC_INIT, AM_INIT_AUTOMAKE
      build: avoid use of deprecated INCLUDES
      build: use simpler autoreconf in autogen
      build: use AC_CONFIG_MACRO_DIR as directed
      build: run AC_CANONICAL_HOST only
      build: remove statements without effect
      build: remove -fPIC flag
      Add .gitignore files
      build: use AC_OUTPUT
      build: default to not building static libraries
      Remove distro-specific parts
      src: remove redundant casts
      build: remove unused LIBTOOL_DEPS
      build: use -Wall across the entire source
      utils: resolve compiler warning
      nfnl: avoid exit on large packet
      build: fix error with automake-1.9
      Update .gitignore
      build: use AC_CONFIG_AUX_DIR and stash away tools
      build: disable implicit .tar.gz archive generation and use POSIX mode
      build: remove unnecessary AC_EXEEXT

Jiri Popelka (1):
      src: BAD_SIZEOF

Pablo Neira Ayuso (13):
      src: add COPYING file that include licensing terms
      iftable: fix wrong handler unregistration on error
      license: upgrade to GPLv2+
      Merge branch 'master' of git://dev.medozas.de/libnfnetlink
      build: kernel-like compilation messages
      src: update copyright header
      utils: iftest: display link state (UP/DOWN)
      utils: iftest: pass the device name you want to obtain information for
      utils: iftest: check return value of nlif_query
      utils: iftest: relax check of nlif_name2index
      iftable: fix incomplete list of interfaces via nlif_query
      nfnl: fix compilation warning with gcc-4.7
      bump version to 1.0.1


--u3/rZRmxL6MmkK24--
