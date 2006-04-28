From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/6] tg3: Update version and reldate
Date: Fri, 28 Apr 2006 16:36:30 -0700
Message-ID: <1146267390.4780.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:44555 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1030278AbWD2BRA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 21:17:00 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update version to 3.57.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0779544..beeb612 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,8 +69,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.56"
-#define DRV_MODULE_RELDATE	"Apr 1, 2006"
+#define DRV_MODULE_VERSION	"3.57"
+#define DRV_MODULE_RELDATE	"Apr 28, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


