From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] l2tp: Add missing semicolon to MODULE_ALIAS() in
 l2tp_netlink.c
Date: Sat, 03 Apr 2010 15:04:35 -0700 (PDT)
Message-ID: <20100403.150435.85210092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60752
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752534Ab0DCWEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 18:04:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 12341a6..4c1e540 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -837,4 +837,4 @@ MODULE_DESCRIPTION("L2TP netlink");
 MODULE_LICENSE("GPL");
 MODULE_VERSION("1.0");
 MODULE_ALIAS("net-pf-" __stringify(PF_NETLINK) "-proto-" \
-	     __stringify(NETLINK_GENERIC) "-type-" "l2tp")
+	     __stringify(NETLINK_GENERIC) "-type-" "l2tp");
-- 
1.7.0.4

