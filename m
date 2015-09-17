From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnftnl 1.0.5 release
Date: Thu, 17 Sep 2015 15:08:06 +0200
Message-ID: <20150917130806.GA21428@salvia>
References: <20150916115004.GA1102@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="u3/rZRmxL6MmkK24"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43870 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042AbbIQNBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 09:01:32 -0400
Content-Disposition: inline
In-Reply-To: <20150916115004.GA1102@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnftnl 1.0.5

libnftnl is a userspace library providing a low-level netlink
programming interface (API) to the in-kernel nf_tables subsystem. The
library libnftnl has been previously known as libnftables. This
library is currently used by the nft command line tool.

This release resolves problems with LIBVERSION and symbol versioning
with regards to 1.0.4.

You can download this library from:

http://www.netfilter.org/projects/libnftnl/downloads.html
ftp://ftp.netfilter.org/pub/libnftnl/

Thanks!

--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnftnl-1.0.5.txt"

Jan Engelhardt (1):
      build: bump library versioning

Pablo Neira Ayuso (1):
      bump version to 1.0.5


--u3/rZRmxL6MmkK24--
