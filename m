From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 01/19] batman-adv: Start new development cycle
Date: Thu,  6 Apr 2017 16:07:23 +0200
Message-ID: <20170406140741.30745-2-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32896 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934788AbdDFOHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:47 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 57a8103dbce7..f87b17c613a6 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -24,7 +24,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2017.0"
+#define BATADV_SOURCE_VERSION "2017.1"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
2.11.0
