From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnetfilter_queue 1.0.2 release
Date: Mon, 8 Oct 2012 12:49:24 +0200
Message-ID: <20121008104924.GA22039@1984>
References: <20121008092636.GA15925@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121008092636.GA15925@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnetfilter_queue 1.0.2

This release provides new interfaces to interact with libmnl.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libnetfilter_queue/downloads.html
ftp://ftp.netfilter.org/pub/libnetfilter_queue/

Have fun!

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_queue-1.0.2.txt"

Jan Engelhardt (3):
      build: remove unnecessary AC_EXEEXT
      build: remove unused lines in Makefile.am
      build: remove stray empty variable

Krishna Kumar (1):
      src: implement API to set per-queue flags

Pablo Neira Ayuso (9):
      add new libnetfilter_queue API for libmnl
      add pkt_buff and protocol helper functions
      add mangle functions for IPv4/TCP and IPv4/UDP
      extra: pktbuff: pktb_expand_tail return 0 if there is no room in the tail
      pktbuff: fix pktb_push, _pull and _put function
      src: update doxygen documentation for new API for libmnl
      examples: nf-queue: fix compilation warning with gcc-4.7
      fix compilation warning in nfq_get_payload
      bump version to 1.0.2


--ew6BAiZeqk4r7MaW--
