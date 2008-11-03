From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 15/15] tg3: Update version to 3.95
Date: Mon, 3 Nov 2008 04:22:27 -0800
Message-ID: <1225751633.6208@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2836 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756776AbYKCWeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:34:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the version to 3.95.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c48bb51..babf83d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,8 +69,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.94"
-#define DRV_MODULE_RELDATE	"August 14, 2008"
+#define DRV_MODULE_VERSION	"3.95"
+#define DRV_MODULE_RELDATE	"November 3, 2008"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.5.6.4



