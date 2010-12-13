From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 9/9] bnx2x: update version to 1.62.00-2
Date: Mon, 13 Dec 2010 17:44:50 +0200
Message-ID: <1292255090.631.57.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4162 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754458Ab0LMPpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 10:45:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 66b3b60..b707a11 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -22,8 +22,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */

-#define DRV_MODULE_VERSION      "1.60.00-7"
-#define DRV_MODULE_RELDATE      "2010/12/08"
+#define DRV_MODULE_VERSION      "1.62.00-2"
+#define DRV_MODULE_RELDATE      "2010/12/13"
 #define BNX2X_BC_VER            0x040200

 #define BNX2X_MULTI_QUEUE
--
1.7.0.4




