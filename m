From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 1/2] batman-adv: Start new development cycle
Date: Mon,  7 Jan 2013 12:11:27 +0100
Message-ID: <1357557088-17866-2-git-send-email-ordex@autistici.org>
References: <1357557088-17866-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:58710 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769Ab3AGLM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 06:12:28 -0500
In-Reply-To: <1357557088-17866-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 2f85577..5d994a6 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -26,7 +26,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2012.5.0"
+#define BATADV_SOURCE_VERSION "2013.0.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.8.0.2
