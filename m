From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 11/11][TG3]: Update version and reldate.
Date: Fri, 04 May 2007 17:55:26 -0700
Message-ID: <1178326526.4859.27.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4066 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423004AbXEEAIR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:08:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Update version and reldate.

Update version to 3.76.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c264eb0..7124924 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.75"
-#define DRV_MODULE_RELDATE	"March 23, 2007"
+#define DRV_MODULE_VERSION	"3.76"
+#define DRV_MODULE_RELDATE	"May 4, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


