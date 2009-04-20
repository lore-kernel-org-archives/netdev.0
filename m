From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 8/8] tg3: Update version to 3.99
Date: Mon, 20 Apr 2009 10:13:31 -0700
Message-ID: <1240247961.7030@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1567 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbZDTRTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 13:19:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.99.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f2b7ff8..eb65e25 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.98"
-#define DRV_MODULE_RELDATE	"February 25, 2009"
+#define DRV_MODULE_VERSION	"3.99"
+#define DRV_MODULE_RELDATE	"April 20, 2009"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.6.0.6


