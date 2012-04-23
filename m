From: "Barak Witkowski" <barak@broadcom.com>
Subject: [PATCH net-next 3/3] bnx2x: Update driver version to 1.72.50-0
Date: Mon, 23 Apr 2012 16:05:16 +0300
Message-ID: <1335186316.14229.29.camel@lb-tlvb-barak.il.broadcom.com>
Reply-To: barak@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4268 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752577Ab2DWNJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2012 09:09:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 42bb145..e30e2a2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -23,8 +23,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.72.17-0"
-#define DRV_MODULE_RELDATE      "2012/04/02"
+#define DRV_MODULE_VERSION      "1.72.50-0"
+#define DRV_MODULE_RELDATE      "2012/04/23"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
-- 
1.7.9
