From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/3] tg3: Update version and reldate
Date: Tue, 25 Jul 2006 15:56:26 -0700
Message-ID: <1153868186.3167.28.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sdoyon@max-t.com, howie@vmware.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:62218 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030218AbWGYWyw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 18:54:52 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update version to 3.63.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d66b06f..1b8138f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.62"
-#define DRV_MODULE_RELDATE	"June 30, 2006"
+#define DRV_MODULE_VERSION	"3.63"
+#define DRV_MODULE_RELDATE	"July 25, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


