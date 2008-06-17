From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 15/15]bnx2x: Update version
Date: Tue, 17 Jun 2008 17:58:37 +0300
Message-ID: <1213714717.5817.187.camel@lb-tlvb-eliezer>
References: <1213714193.5817.185.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2208 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbYFQO6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 10:58:49 -0400
In-Reply-To: <1213714193.5817.185.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-sending with the right subject: 15/15
Updating to version 1.45.3

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 911669f..079e9c7 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -66,8 +66,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION      "1.42.4"
-#define DRV_MODULE_RELDATE      "2008/4/9"
+#define DRV_MODULE_VERSION      "1.45.3"
+#define DRV_MODULE_RELDATE      "2008/6/1"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung. */
-- 
1.5.3.2




