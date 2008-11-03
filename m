From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 4/4]bnx2x: Version Update
Date: Mon, 03 Nov 2008 18:11:26 +0200
Message-ID: <1225728686.14568.13.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3896 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755761AbYKCQLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 11:11:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updating the version

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5b013d8..600210d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -59,8 +59,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION	"1.45.22"
-#define DRV_MODULE_RELDATE	"2008/09/09"
+#define DRV_MODULE_VERSION	"1.45.23"
+#define DRV_MODULE_RELDATE	"2008/11/03"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung */
-- 
1.5.4.3




