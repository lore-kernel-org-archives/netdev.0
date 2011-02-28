From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 7/7] bnx2x: update driver version to 1.62.00-6
Date: Mon, 28 Feb 2011 15:37:09 +0200
Message-ID: <1298900229.28024.115.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4080 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753727Ab1B1Nij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 08:38:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 368cfcd..7897d11 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -22,7 +22,7 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.62.00-5"
+#define DRV_MODULE_VERSION      "1.62.00-6"
 #define DRV_MODULE_RELDATE      "2011/01/30"
 #define BNX2X_BC_VER            0x040200
 
-- 
1.7.2.2




