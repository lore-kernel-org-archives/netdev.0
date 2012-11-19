From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/10] batman-adv: Start new development cycle
Date: Mon, 19 Nov 2012 09:24:10 +0100
Message-ID: <1353313451-2930-10-git-send-email-ordex@autistici.org>
References: <1353313451-2930-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:64275 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab2KSIZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 03:25:27 -0500
In-Reply-To: <1353313451-2930-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 0213cb5..e2b7e1a 100644
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
