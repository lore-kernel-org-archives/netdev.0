From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/5] tg3: Update version and reldate
Date: Thu, 29 Jun 2006 18:29:36 -0700
Message-ID: <1151630976.21798.21.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:62732 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751391AbWF3B2b
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 21:28:31 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update version to 3.61.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 63d4b2c..47c96fc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,8 +69,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.60"
-#define DRV_MODULE_RELDATE	"June 17, 2006"
+#define DRV_MODULE_VERSION	"3.61"
+#define DRV_MODULE_RELDATE	"June 29, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


