From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v4 net-next 6/6] bnx2x: update version to 1.78.17-0
Date: Mon, 22 Apr 2013 16:48:11 +0300
Message-ID: <1366638491-27184-7-git-send-email-dmitry@broadcom.com>
References: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fz.zoreil.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3995 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771Ab3DVNsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 09:48:37 -0400
In-Reply-To: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 87629fd..3dba2a7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -26,8 +26,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.78.02-0"
-#define DRV_MODULE_RELDATE      "2013/01/14"
+#define DRV_MODULE_VERSION      "1.78.17-0"
+#define DRV_MODULE_RELDATE      "2013/04/11"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
-- 
1.8.1.4
