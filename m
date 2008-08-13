From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 25/25] bnx2x: Version update
Date: Wed, 13 Aug 2008 17:16:32 +0300
Message-ID: <1218636992.547.101.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2057 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755951AbYHMOQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:16:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version update

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f285f0b..3e7dc17 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -60,8 +60,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION      "1.45.6"
-#define DRV_MODULE_RELDATE      "2008/06/23"
+#define DRV_MODULE_VERSION      "1.45.17"
+#define DRV_MODULE_RELDATE      "2008/08/13"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung */
-- 
1.5.3.2




