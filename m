From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 14/15] batman-adv: Start new development cycle
Date: Mon, 29 Feb 2016 19:06:07 +0800
Message-ID: <1456743968-17562-15-git-send-email-a@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:8727 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753848AbcB2LUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:20:10 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 878c35974845..db4533631834 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -24,7 +24,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2016.0"
+#define BATADV_SOURCE_VERSION "2016.1"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
2.7.2
