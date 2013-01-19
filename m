From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/13] batman-adv: Start new development cycle
Date: Sat, 19 Jan 2013 21:27:59 +0800
Message-ID: <1358602079-24024-14-git-send-email-ordex@autistici.org>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:58445 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923Ab3ASNaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:30:16 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 74eb960..ced08b9 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -26,7 +26,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2012.5.0"
+#define BATADV_SOURCE_VERSION "2013.1.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.8.0.2
