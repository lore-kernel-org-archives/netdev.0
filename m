From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/4][TG3]: Update version and reldate.
Date: Fri, 15 Dec 2006 22:49:06 -0800
Message-ID: <1166251746.30429.12.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2775 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030615AbWLPF7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Dec 2006 00:59:37 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Update version and reldate.

Update version to 3.71.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6ee399c..cfdbca2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.70"
-#define DRV_MODULE_RELDATE	"December 1, 2006"
+#define DRV_MODULE_VERSION	"3.71"
+#define DRV_MODULE_RELDATE	"December 15, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


