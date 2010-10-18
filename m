From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 6/6] bnx2x: update version to 1.60.00-2
Date: Mon, 18 Oct 2010 11:08:55 +0200
Message-ID: <1287392935.11597.40.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1683 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754626Ab0JRJMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 05:12:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 7d7af10..b387717 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -20,8 +20,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.60.00-1"
-#define DRV_MODULE_RELDATE      "2010/10/06"
+#define DRV_MODULE_VERSION      "1.60.00-2"
+#define DRV_MODULE_RELDATE      "2010/10/18"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-- 
1.7.2.2




