From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 01/13] batman-adv: properly rename define in distributed arp table header file
Date: Thu,  9 Jan 2014 15:52:50 +0100
Message-ID: <1389279182-3256-2-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:44779 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaAIOyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:54:23 -0500
In-Reply-To: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/distributed-arp-table.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 60d853b..79a078b 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -17,8 +17,8 @@
  * 02110-1301, USA
  */
 
-#ifndef _NET_BATMAN_ADV_ARP_H_
-#define _NET_BATMAN_ADV_ARP_H_
+#ifndef _NET_BATMAN_ADV_DISTRIBUTED_ARP_TABLE_H_
+#define _NET_BATMAN_ADV_DISTRIBUTED_ARP_TABLE_H_
 
 #ifdef CONFIG_BATMAN_ADV_DAT
 
@@ -169,4 +169,4 @@ static inline void batadv_dat_inc_counter(struct batadv_priv *bat_priv,
 
 #endif /* CONFIG_BATMAN_ADV_DAT */
 
-#endif /* _NET_BATMAN_ADV_ARP_H_ */
+#endif /* _NET_BATMAN_ADV_DISTRIBUTED_ARP_TABLE_H_ */
-- 
1.8.5.2
