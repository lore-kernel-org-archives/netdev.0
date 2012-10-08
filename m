From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnetfilter_acct 1.0.1 release
Date: Tue, 9 Oct 2012 00:49:19 +0200
Message-ID: <20121008224919.GA6616@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnetfilter_acct 1.0.1

This release adds the new flag NFACCT_SNPRINTF_T_XML for
nfacct_snprintf and several cleanups.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libnetfilter_acct/downloads.html
ftp://ftp.netfilter.org/pub/libnetfilter_acct/

Have fun!

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_acct-1.0.1.txt"

Jan Engelhardt (1):
      build: remove unnecessary pkgconfig->config.status dependency

Pablo Neira Ayuso (4):
      src: NFACCT_SNPRINTF_T_XML flag for nfacct_snprintf to output time
      build: bump version to 1.0.1
      src: remove unnecessary castings
      src: NFACCT_PKTS and NFACCT_BYTES are MNL_TYPE_U64


--LQksG6bCIzRHxTLp--
