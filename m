From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 09/15] batman-adv: Fix kerneldoc for batadv_compare_claim
Date: Wed,  4 May 2016 06:23:44 +0800
Message-ID: <1462314230-16257-10-git-send-email-a@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:40244 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756804AbcECWYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:24:50 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bridge_loop_avoidance.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 20b2fd9b3d72..60d33232bd10 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -120,7 +120,7 @@ static int batadv_compare_backbone_gw(const struct hlist_node *node,
 }
 
 /**
- * batadv_compare_backbone_gw - compare address and vid of two claims
+ * batadv_compare_claim - compare address and vid of two claims
  * @node: list node of the first entry to compare
  * @data2: pointer to the second claims
  *
-- 
2.8.2
