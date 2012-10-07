From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.16.1 release
Date: Mon, 8 Oct 2012 01:17:06 +0200
Message-ID: <20121007231706.GA7400@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 08, 2012 at 12:24:41AM +0200, Pablo Neira Ayuso wrote:
Hi!

The Netfilter project proudly presents:

        iptables 1.4.16.1

This release fixes a major breakage introduced by:

commit cd2f9bdbb7f9b737e5d640aafeb78bcd8e3a7adf
Author: Jan Engelhardt <jengelh@inai.de>
Date:   Tue Sep 4 05:24:47 2012 +0200

    iptables: support for target aliases

This is really unfortunate, it seems this patch has been pushed
mainstream without sufficient testing. We are really sorry for the
inconvenience. Please, don't use 1.4.16, this bug reders it
completely useless.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

Have fun!

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-iptables-1.4.16.1.txt"

Pablo Neira Ayuso (2):
      iptables: fix standard target
      bump version to 1.4.16.1


--HlL+5n6rz5pIUxbD--
