From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH resend 2.6.25 11/12][BNX2X]: update version
Date: Mon, 25 Feb 2008 12:33:11 +0200
Message-ID: <1203935591.8232.215.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.31.210.20] ([216.31.210.20]:3704 "EHLO mms5.broadcom.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754106AbYBYKlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 05:41:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: update version

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 2db0427..6db4805 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -63,8 +63,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION      "0.40.15"
-#define DRV_MODULE_RELDATE      "$DateTime: 2007/11/15 07:28:37 $"
+#define DRV_MODULE_VERSION      "1.40.22"
+#define DRV_MODULE_RELDATE      "$DateTime: 2008/02/23 20:21:47 $"
 #define BNX2X_BC_VER    	0x040200
 
 /* Time in jiffies before concluding the transmitter is hung. */
-- 
1.5.3.2




