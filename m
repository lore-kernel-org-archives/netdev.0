From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 11/12][BNX2X]: update version, remove CVS strings
Date: Wed, 27 Feb 2008 14:25:02 +0200
Message-ID: <1204115102.8232.366.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms5.broadcom.com ([216.31.210.20]:4250 "EHLO mms5.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754622AbYB0Mbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 07:31:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: update version, remove CVS strings

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 2db0427..8af142c 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -63,8 +63,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION      "0.40.15"
-#define DRV_MODULE_RELDATE      "$DateTime: 2007/11/15 07:28:37 $"
+#define DRV_MODULE_VERSION      "1.40.22"
+#define DRV_MODULE_RELDATE      "2007/11/27"
 #define BNX2X_BC_VER    	0x040200
 
 /* Time in jiffies before concluding the transmitter is hung. */
@@ -78,7 +78,6 @@ MODULE_AUTHOR("Eliezer Tamir <eliezert@broadcom.com>");
 MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
-MODULE_INFO(cvs_version, "$Revision: #404 $");
 
 static int use_inta;
 static int poll;
-- 
1.5.3.2




