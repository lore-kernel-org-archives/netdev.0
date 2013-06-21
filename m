From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] bridge: fix a typo in comments
Date: Fri, 21 Jun 2013 15:37:25 +0800
Message-ID: <1371800245-23494-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965317Ab3FUHhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 03:37:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 31952a1..81befac 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1012,7 +1012,7 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 #endif
 
 /*
- * Add port to rotuer_list
+ * Add port to router_list
  *  list is maintained ordered by pointer value
  *  and locked by br->multicast_lock and RCU
  */
