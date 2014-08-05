From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 4/4] batman-adv: Start new development cycle
Date: Tue,  5 Aug 2014 09:36:28 +0200
Message-ID: <1407224188-28626-5-git-send-email-antonio@meshcoding.com>
References: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:25340 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756496AbaHEHhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 03:37:21 -0400
In-Reply-To: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 257840e..a1fcd88 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -24,7 +24,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2014.3.0"
+#define BATADV_SOURCE_VERSION "2014.4.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.8.5.5
