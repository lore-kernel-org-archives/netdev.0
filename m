From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 18/18] batman-adv: Start new development cycle
Date: Thu, 23 Aug 2012 15:10:27 +0200
Message-ID: <1345727427-20805-19-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28751 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933731Ab2HWNLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:11:09 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 61a0cfd..d57b746 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -26,7 +26,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2012.3.0"
+#define BATADV_SOURCE_VERSION "2012.4.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.7.9.4
