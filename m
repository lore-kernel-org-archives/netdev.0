From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/7] tg3: Update version to 3.94
Date: Fri, 15 Aug 2008 14:03:56 -0700
Message-ID: <1218834770.6490@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3925 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460AbYHOU1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 16:27:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the version number to 3.94.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ada1d0d..71d2c5c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -66,8 +66,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.93"
-#define DRV_MODULE_RELDATE	"May 22, 2008"
+#define DRV_MODULE_VERSION	"3.94"
+#define DRV_MODULE_RELDATE	"August 14, 2008"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.5.6.4



