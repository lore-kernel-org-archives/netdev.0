From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-2.6 8/8] bnx2x: Update version number
Date: Mon, 1 Nov 2010 17:32:43 +0200
Message-ID: <1288625563.3533.20.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2339 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757426Ab0KAMOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 08:14:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update bnx2x version number.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 9eea225..863e73a 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -20,8 +20,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.60.00-3"
-#define DRV_MODULE_RELDATE      "2010/10/19"
+#define DRV_MODULE_VERSION      "1.60.00-4"
+#define DRV_MODULE_RELDATE      "2010/11/01"
 #define BNX2X_BC_VER            0x040200
 
 #define BNX2X_MULTI_QUEUE
-- 
1.7.1




