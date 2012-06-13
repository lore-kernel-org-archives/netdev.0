From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 12/12] bnx2x: Change date and version to
 1.72.51-0
Date: Wed, 13 Jun 2012 15:44:24 +0300
Message-ID: <1339591464-10554-13-git-send-email-meravs@broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2760 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979Ab2FMJnE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:43:04 -0400
In-Reply-To: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change updates the date and version of the bnx2x driver.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index e30e2a2..85a3b84 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -23,8 +23,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.72.50-0"
-#define DRV_MODULE_RELDATE      "2012/04/23"
+#define DRV_MODULE_VERSION      "1.72.51-0"
+#define DRV_MODULE_RELDATE      "2012/06/12"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
-- 
1.7.10
