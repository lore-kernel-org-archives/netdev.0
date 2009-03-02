From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 18/18] bnx2x: Version update
Date: Mon, 02 Mar 2009 20:01:17 +0200
Message-ID: <1236016877.7723.91.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3108 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757117AbZCBSCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:02:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 18/18] bnx2x: Version update

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 09d802a..00a78e8 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -55,8 +55,8 @@
 #include "bnx2x_init.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.48.102"
-#define DRV_MODULE_RELDATE	"2009/02/12"
+#define DRV_MODULE_VERSION	"1.48.105"
+#define DRV_MODULE_RELDATE	"2009/03/02"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung */
-- 
1.5.4.3




