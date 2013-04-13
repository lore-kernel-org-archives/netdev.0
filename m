From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 4/4] bnx2x: update version to 1.78.17-0
Date: Sat, 13 Apr 2013 11:56:51 +0300
Message-ID: <1365843411-27103-5-git-send-email-dmitry@broadcom.com>
References: <1365843411-27103-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2111 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751957Ab3DMI5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 04:57:06 -0400
In-Reply-To: <1365843411-27103-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

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
1.7.7.2
