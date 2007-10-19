From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/7] tg3: Update version to 3.85
Date: Fri, 19 Oct 2007 14:37:00 -0700
Message-ID: <1192829821.22064.561.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3016 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935744AbXJSVhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 17:37:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch updates the version number to 3.85.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d866387..e5cf97a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.84"
-#define DRV_MODULE_RELDATE	"October 12, 2007"
+#define DRV_MODULE_VERSION	"3.85"
+#define DRV_MODULE_RELDATE	"October 18, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


