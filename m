From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 6/8] batman-adv: Start new development cycle
Date: Mon, 14 May 2012 09:17:36 +0200
Message-ID: <1336979858-13928-7-git-send-email-ordex@autistici.org>
References: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:51813 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754569Ab2ENHRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:17:12 -0400
In-Reply-To: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index fd83acd..f4a3ec0 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -28,7 +28,7 @@
 #define DRIVER_DEVICE "batman-adv"
 
 #ifndef SOURCE_VERSION
-#define SOURCE_VERSION "2012.1.0"
+#define SOURCE_VERSION "2012.2.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.7.9.4
