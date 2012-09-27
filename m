From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 2/2] bnx2x: Update version to 1.78.00-0.
Date: Thu, 27 Sep 2012 16:58:56 +0200
Message-ID: <1348757936-10262-3-git-send-email-yuvalmin@broadcom.com>
References: <1348757936-10262-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4099 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755126Ab2I0P0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 11:26:33 -0400
In-Reply-To: <1348757936-10262-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 6d1a24a..3865084 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -23,8 +23,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.72.51-0"
-#define DRV_MODULE_RELDATE      "2012/06/18"
+#define DRV_MODULE_VERSION      "1.78.00-0"
+#define DRV_MODULE_RELDATE      "2012/09/27"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
-- 
1.7.9.rc2
