From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 10/10] bnx2x: Update bnx2x version to 1.62.11-0
Date: Mon, 31 Jan 2011 16:22:57 +0200
Message-ID: <1296483777.17181.120.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3424 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755208Ab1AaOZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 09:25:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update bnx2x version to 1.62.11-0

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index dfdb9b5..04fb72b 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -22,8 +22,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.62.00-4"
-#define DRV_MODULE_RELDATE      "2011/01/18"
+#define DRV_MODULE_VERSION      "1.62.11-0"
+#define DRV_MODULE_RELDATE      "2011/01/31"
 #define BNX2X_BC_VER            0x040200
 
 #define BNX2X_MULTI_QUEUE
-- 
1.7.1







