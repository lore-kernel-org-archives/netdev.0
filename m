From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 5/6] vxge: Update maintainers information
Date: Thu, 15 Jul 2010 13:47:27 -0500
Message-ID: <1279219648-10345-5-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:56046 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934236Ab0GOSro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 14:47:44 -0400
Received: by mail-px0-f174.google.com with SMTP id 14so527635pxi.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 11:47:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update and correct maintainers information

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
---
 MAINTAINERS |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index bb6493b..c05b499 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3893,17 +3893,19 @@ L:	netem@lists.linux-foundation.org
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
-- 
1.7.0.4

