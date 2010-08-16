From: "Yaniv Rosner" <yaniv.home@broadcom.com>
Subject: [net-2.6 2/2] bnx2x: Update bnx2x version to 1.52.53-4
Date: Mon, 16 Aug 2010 19:34:07 +0300
Message-ID: <1281976447.3997.18.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2556 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904Ab0HPNPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 09:15:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update bnx2x version to 1.52.53-4

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 53af9c9..5fe78f7 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -20,7 +20,7 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.52.53-3"
-#define DRV_MODULE_RELDATE      "2010/18/04"
+#define DRV_MODULE_VERSION      "1.52.53-4"
+#define DRV_MODULE_RELDATE      "2010/16/08"
 #define BNX2X_BC_VER            0x040200
 




