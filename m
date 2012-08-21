From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] iproute2: Add missing tc-ematch.8 for man page installation
Date: Tue, 21 Aug 2012 07:16:29 +0200
Message-ID: <503319AD.2090701@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:31282 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554Ab2HUFQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 01:16:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/man/man8/Makefile b/man/man8/Makefile
index c344094..2556564 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -1,7 +1,7 @@
 TARGETS = ip-address.8 ip-link.8 ip-route.8
 
 MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
-	tc-bfifo.8 tc-cbq-details.8 tc-cbq.8 tc-drr.8 tc-htb.8 \
+	tc-bfifo.8 tc-cbq-details.8 tc-cbq.8 tc-drr.8 tc-ematch.8 tc-htb.8 \
 	tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 tc-sfq.8 \
 	tc-tbf.8 tc.8 tc-codel.8 tc-fq_codel.8 tc-sfb.8 tc-netem.8 tc-choke.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
