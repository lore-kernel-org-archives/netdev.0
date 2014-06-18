From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/13] MAINTAINERS: merge ebtables into netfilter entry
Date: Wed, 18 Jun 2014 11:44:39 +0200
Message-ID: <1403084679-11227-14-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41479 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965716AbaFRJpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 05:45:00 -0400
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moreover, remove reference to the netfilter users mailing list,
so they don't receive patches.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 MAINTAINERS |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 134483f..2d67a5d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3189,14 +3189,6 @@ L:	linux-scsi@vger.kernel.org
 S:	Maintained
 F:	drivers/scsi/eata_pio.*
 
-EBTABLES
-L:	netfilter-devel@vger.kernel.org
-W:	http://ebtables.sourceforge.net/
-S:	Orphan
-F:	include/linux/netfilter_bridge/ebt_*.h
-F:	include/uapi/linux/netfilter_bridge/ebt_*.h
-F:	net/bridge/netfilter/ebt*.c
-
 EC100 MEDIA DRIVER
 M:	Antti Palosaari <crope@iki.fi>
 L:	linux-media@vger.kernel.org
@@ -6105,12 +6097,11 @@ F:	Documentation/networking/s2io.txt
 F:	Documentation/networking/vxge.txt
 F:	drivers/net/ethernet/neterion/
 
-NETFILTER/IPTABLES
+NETFILTER ({IP,IP6,ARP,EB,NF}TABLES)
 M:	Pablo Neira Ayuso <pablo@netfilter.org>
 M:	Patrick McHardy <kaber@trash.net>
 M:	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
 L:	netfilter-devel@vger.kernel.org
-L:	netfilter@vger.kernel.org
 L:	coreteam@netfilter.org
 W:	http://www.netfilter.org/
 W:	http://www.iptables.org/
-- 
1.7.10.4
