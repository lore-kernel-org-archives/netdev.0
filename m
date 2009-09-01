From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 18/18] tg3: Update version to 3.102
Date: Tue, 1 Sep 2009 16:22:42 -0700
Message-ID: <1251867317.5965@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4129 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932147AbZIBEz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.102.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a7eb6a0..b669b6f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.101"
-#define DRV_MODULE_RELDATE	"August 28, 2009"
+#define DRV_MODULE_VERSION	"3.102"
+#define DRV_MODULE_RELDATE	"September 1, 2009"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.6.3.3


