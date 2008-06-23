From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 15/15]bnx2x: Update version
Date: Mon, 23 Jun 2008 19:02:53 +0300
Message-ID: <1214236973.3690.58.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2765 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754540AbYFWQDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 12:03:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updating to version 1.45.6

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index d21dc89..0263bef 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -60,8 +60,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION      "1.42.4"
-#define DRV_MODULE_RELDATE      "2008/4/9"
+#define DRV_MODULE_VERSION      "1.45.6"
+#define DRV_MODULE_RELDATE      "2008/06/23"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung */
-- 
1.5.3.2




