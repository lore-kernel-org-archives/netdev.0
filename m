From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 8/8] tg3: Update version to 3.93
Date: Thu, 22 May 2008 19:57:13 -0700
Message-ID: <1211511433.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3676 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763099AbYEWCxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 22:53:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch increments the version to 3.93.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d0dd92c..f753eb1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -66,8 +66,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.92"
-#define DRV_MODULE_RELDATE	"May 2, 2008"
+#define DRV_MODULE_VERSION	"3.93"
+#define DRV_MODULE_RELDATE	"May 22, 2008"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


