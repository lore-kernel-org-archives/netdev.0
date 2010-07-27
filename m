From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 7/8] bnx2x: update driver version to 1.52.53-3
Date: Wed, 28 Jul 2010 01:37:06 +0300
Message-ID: <1280270226.11551.115.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4331 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946Ab0G0Wmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 18:42:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 383e13e..817b088 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -20,7 +20,7 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.52.53-1"
+#define DRV_MODULE_VERSION      "1.52.53-3"
 #define DRV_MODULE_RELDATE      "2010/18/04"
 #define BNX2X_BC_VER            0x040200
 
-- 
1.7.1




