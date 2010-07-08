From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 5/6 net-next-2.6] vxge: Update maintainers information
Date: Thu, 8 Jul 2010 14:23:24 -0500
Message-ID: <20100708192324.GE15167@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ramkrishna Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:61624 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758456Ab0GHTWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 15:22:47 -0400
Received: by pxi14 with SMTP id 14so449798pxi.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 12:22:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update and correct maintainers information

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>
---
 MAINTAINERS |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2ebb567..28cd736 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3895,17 +3895,19 @@ L:	netem@lists.linux-foundation.org
 S:	Maintained
 F:	net/sched/sch_netem.c
 
-NETERION (S2IO) 10GbE DRIVER (xframe/vxge)
-M:	Ramkrishna Vepa <ram.vepa@neterion.com>
-M:	Rastapur Santosh <santosh.rastapur@neterion.com>
-M:	Sivakumar Subramani <sivakumar.subramani@neterion.com>
-M:	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
+NETERION 10GbE DRIVERS (s2io/vxge)
+M:	Ramkrishna Vepa <ramkrishna.vepa@exar.com>
+M:	Sivakumar Subramani <sivakumar.subramani@exar.com>
+M:	Sreenivasa Honnur <sreenivasa.honnur@exar.com>
+M:	Jon Mason <jon.mason@exar.com>
 L:	netdev@vger.kernel.org
 W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/Linux?Anonymous
 W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/X3100Linux?Anonymous
 S:	Supported
 F:	Documentation/networking/s2io.txt
 F:	drivers/net/s2io*
+F:	Documentation/networking/vxge.txt
+F:	drivers/net/vxge/
 
 NETFILTER/IPTABLES/IPCHAINS
 P:	Rusty Russell
