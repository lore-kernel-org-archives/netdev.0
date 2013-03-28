From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/11] batman-adv: Start new development cycle
Date: Thu, 28 Mar 2013 08:50:29 +0100
Message-ID: <1364457031-3194-10-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33424 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756681Ab3C1HwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:14 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index a9e12e6..f90f5bc 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -26,7 +26,7 @@
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
 #ifndef BATADV_SOURCE_VERSION
-#define BATADV_SOURCE_VERSION "2013.1.0"
+#define BATADV_SOURCE_VERSION "2013.2.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.8.1.5
