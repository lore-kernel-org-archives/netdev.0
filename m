From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 17/17] tg3: Update version to 3.101
Date: Fri, 28 Aug 2009 17:03:44 -0700
Message-ID: <1251585294.29711@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2439 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752611AbZH2WfC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:35:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.101.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e36b0b2..a7d14aa 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.100"
-#define DRV_MODULE_RELDATE	"August 25, 2009"
+#define DRV_MODULE_VERSION	"3.101"
+#define DRV_MODULE_RELDATE	"August 28, 2009"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.6.3.3


