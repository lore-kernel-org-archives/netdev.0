From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 9/9][TG3]: Update version and reldate.
Date: Wed, 27 Sep 2006 13:35:24 -0700
Message-ID: <1159389324.3411.26.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23314 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030796AbWI0Uit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:38:49 -0400
To: davem@davemloft.net, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Update version and reldate.

Update version to 3.66.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 21843de..c25ba27 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.65"
-#define DRV_MODULE_RELDATE	"August 07, 2006"
+#define DRV_MODULE_VERSION	"3.66"
+#define DRV_MODULE_RELDATE	"September 23, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


