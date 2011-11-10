From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 13/13] bnx2x: update driver version to
 1.70.35-0
Date: Thu, 10 Nov 2011 17:14:14 +0200
Message-ID: <1320938054-31288-14-git-send-email-dmitry@broadcom.com>
References: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2416 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933924Ab1KJPOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 10:14:49 -0500
In-Reply-To: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 78613ef..4b90b51 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -23,8 +23,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.70.30-0"
-#define DRV_MODULE_RELDATE      "2011/10/25"
+#define DRV_MODULE_VERSION      "1.70.35-0"
+#define DRV_MODULE_RELDATE      "2011/11/10"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
-- 
1.7.7.2
