From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 8/8] tg3: Update version to 3.87
Date: Thu, 20 Dec 2007 15:21:48 -0800
Message-ID: <1198192908.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1087 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755644AbXLTXVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 18:21:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the version number to 3.87.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index dd9229c..6264454 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.86"
-#define DRV_MODULE_RELDATE	"November 9, 2007"
+#define DRV_MODULE_VERSION	"3.87"
+#define DRV_MODULE_RELDATE	"December 20, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


