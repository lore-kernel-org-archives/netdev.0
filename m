From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 4/4] bnx2x: Update version number and a date.
Date: Wed, 8 Dec 2010 13:43:37 +0200
Message-ID: <1291808617.30114.68.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4125 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065Ab0LHLnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 06:43:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index abbdf6d..7e4d682 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -20,8 +20,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.60.00-6"
-#define DRV_MODULE_RELDATE      "2010/11/29"
+#define DRV_MODULE_VERSION      "1.60.00-7"
+#define DRV_MODULE_RELDATE      "2010/12/08"
 #define BNX2X_BC_VER            0x040200
 
 #define BNX2X_MULTI_QUEUE
-- 
1.7.0.4




