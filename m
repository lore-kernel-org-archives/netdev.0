From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 3/3] batman-adv: Start new development cycle
Date: Sun, 18 May 2014 19:58:10 +0200
Message-ID: <1400435890-6667-4-git-send-email-antonio@meshcoding.com>
References: <1400435890-6667-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:17709 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbaERR7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 13:59:34 -0400
In-Reply-To: <1400435890-6667-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 770dc89..118b990 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -24,7 +24,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2014.2.0"
+#define BATADV_SOURCE_VERSION "2014.3.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.8.5.5
