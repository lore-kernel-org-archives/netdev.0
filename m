From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 24/24] bnx2x: Update date to 2011/06/13 and
 version to 1.70.00-0
Date: Tue, 14 Jun 2011 14:34:46 +0300
Message-ID: <201106141434.46586.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2918 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756372Ab1FNLfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:35:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 3696149..69fc728 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -22,8 +22,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.62.12-0"
-#define DRV_MODULE_RELDATE      "2011/03/20"
+#define DRV_MODULE_VERSION      "1.70.00-0"
+#define DRV_MODULE_RELDATE      "2011/06/13"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
-- 
1.7.4.1


