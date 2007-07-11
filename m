From: "Michael Chan" <mchan@broadcom.com>
Subject: [5/5][TG3]: Update version to 3.78.
Date: Wed, 11 Jul 2007 16:32:37 -0700
Message-ID: <1184196757.5211.12.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, mcarlson@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3478 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934580AbXGKWko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 18:40:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Update version to 3.78.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0d40f9d..3245f16 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.77"
-#define DRV_MODULE_RELDATE	"May 31, 2007"
+#define DRV_MODULE_VERSION	"3.78"
+#define DRV_MODULE_RELDATE	"July 11, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


