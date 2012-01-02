From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [ANNOUNCE] libnetfilter_queue 1.0.1 release
Date: Mon, 2 Jan 2012 20:59:35 +0100
Message-ID: <20120102195935.GB26867@1984>
References: <20120102195845.GA26867@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="n8g4imXOkfNTN/H1"
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120102195845.GA26867@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 02, 2012 at 08:58:45PM +0100, Pablo Neira Ayuso wrote:
> Hi!
> 
> The Netfilter project proudly presents:
> 
>         libnetfilter_queue 1.0.1
> 
> libnetfilter_queue is a userspace library providing an API to packets
> that have been queued by the kernel packet filter.
> 
> See ChangeLog that comes attached to this email for more details.

Forgot to attach, find it here.

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_queue-1.0.1.txt"

Alessandro Vesely (1):
      utils: document ENOBUFS in nfqnl_test.c

Florian Westphal (2):
      src: add NFQNL_MSG_VERDICT_BATCH support
      src: add notes on NF_STOLEN and NF_REPEAT to documentation

Jan Engelhardt (20):
      build: build: use autoconf-suggested naming of files
      build: use modern call syntax for AC_INIT, AM_INIT_AUTOMAKE
      build: avoid use of deprecated INCLUDES
      build: use simpler autoreconf in autogen
      build: run AC_CANONICAL_HOST only
      build: no need for error message in PKG_CHECK_MODULES
      build: set Libs.private for pkgconfig file
      build: remove statements without effect
      build: remove -fPIC flag
      Update .gitignore
      build: default to not building static libraries
      build: use AC_OUTPUT
      build: remove unused LIBTOOL_DEPS
      build: create a Make_global.am file
      build: use -Wall across the entire source
      build: fix error with automake-1.9
      build: fix file list warning with automake-1.9
      Update .gitignore
      build: use AC_CONFIG_AUX_DIR and stash away tools
      build: disable implicit .tar.gz archive generation and use POSIX mode

Pablo Neira Ayuso (11):
      nfq: add missing documentation on nfq_snprintf_xml()
      nfq: add myself to the copyright notice
      nfq: fix redundant LIBVERSION definition
      license: upgrade to GPLv2+
      Merge branch 'master' of git://dev.medozas.de/libnetfilter_queue
      doc: document some performance tweaks for libnetfilter_queue
      Merge branch 'master' of git://dev.medozas.de/libnetfilter_queue
      doc: fix wrong documentation on NFQNL_COPY_NONE
      build: fix `make distcheck'
      build: Linux kernel-style for compilation messages
      build: bump version to 1.0.1


--n8g4imXOkfNTN/H1--
