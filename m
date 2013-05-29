From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 21/21] batman-adv: Start new development cycle
Date: Wed, 29 May 2013 10:12:32 +0200
Message-ID: <1369815152-2750-4-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
 <1369815152-2750-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:50593 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965124Ab3E2IOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:14:31 -0400
In-Reply-To: <1369815152-2750-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 6f25ef2..5e9aebb 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -26,7 +26,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2013.2.0"
+#define BATADV_SOURCE_VERSION "2013.3.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.8.1.5
