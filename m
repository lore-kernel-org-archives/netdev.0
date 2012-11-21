From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 8/9] batman-adv: Start new development cycle
Date: Wed, 21 Nov 2012 13:11:58 +0100
Message-ID: <1353499919-28596-9-git-send-email-ordex@autistici.org>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:50755 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423Ab2KUMNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:13:08 -0500
In-Reply-To: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index ce5e5b9..2f85577 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -26,7 +26,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2012.4.0"
+#define BATADV_SOURCE_VERSION "2012.5.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.8.0
