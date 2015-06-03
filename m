From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/12] batman-adv: iv_ogm, Fix dup_status comment
Date: Wed,  3 Jun 2015 16:14:00 +0200
Message-ID: <1433340848-1682-5-git-send-email-antonio@meshcoding.com>
References: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:14039 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932594AbbFCOQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:16:16 -0400
In-Reply-To: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 66ac9e8..23c41d1 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -28,7 +28,7 @@
 
 /**
  * enum batadv_dup_status - duplicate status
- * @BATADV_NO_DUP: the packet is a duplicate
+ * @BATADV_NO_DUP: the packet is no duplicate
  * @BATADV_ORIG_DUP: OGM is a duplicate in the originator (but not for the
  *  neighbor)
  * @BATADV_NEIGH_DUP: OGM is a duplicate for the neighbor
-- 
2.4.2
