From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/4] tg3: Update version to 3.92.1
Date: Mon, 9 Jun 2008 11:40:53 -0700
Message-ID: <1213046693.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2592 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754784AbYFIVUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 17:20:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch increments the version to 3.92.1.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f8ce873..cc4bde8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.92"
-#define DRV_MODULE_RELDATE	"May 2, 2008"
+#define DRV_MODULE_VERSION	"3.92.1"
+#define DRV_MODULE_RELDATE	"June 9, 2008"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.5.2.5



