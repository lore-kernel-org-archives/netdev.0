From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 01/10] batman-adv: update internal version number
Date: Sat, 26 Nov 2011 22:26:43 +0800
Message-ID: <1322317612-7770-2-git-send-email-lindner_marek@yahoo.de>
References: <1322317612-7770-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm23-vm6.bullet.mail.ukl.yahoo.com ([217.146.176.150]:28948
	"HELO nm23-vm6.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751858Ab1KZO1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2011 09:27:40 -0500
In-Reply-To: <1322317612-7770-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/main.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 964ad4d..86354e0 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -28,7 +28,7 @@
 #define DRIVER_DEVICE "batman-adv"
 
 #ifndef SOURCE_VERSION
-#define SOURCE_VERSION "2011.4.0"
+#define SOURCE_VERSION "2012.0.0"
 #endif
 
 /* B.A.T.M.A.N. parameters */
-- 
1.7.5.4
