From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 9/9] bnx2x: Version update
Date: Mon, 25 Aug 2008 17:25:08 +0300
Message-ID: <1219674308.19456.35.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3159 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700AbYHYO01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:26:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version update

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 95e0582..82deea0 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -59,8 +59,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION      "1.45.17"
-#define DRV_MODULE_RELDATE      "2008/08/13"
+#define DRV_MODULE_VERSION	"1.45.20"
+#define DRV_MODULE_RELDATE	"2008/08/25"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung */
-- 
1.5.3.2




