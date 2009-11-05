From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 10/10] bnx2x: version 1.52.1-3
Date: Thu, 5 Nov 2009 19:18:34 +0200
Message-ID: <1257441514.3390.57.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2445 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756413AbZKEPSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 10:18:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6f16547..61974b7 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -56,8 +56,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.52.1-1"
-#define DRV_MODULE_RELDATE	"2009/10/13"
+#define DRV_MODULE_VERSION	"1.52.1-3"
+#define DRV_MODULE_RELDATE	"2009/11/05"
 #define BNX2X_BC_VER		0x040200
 
 #include <linux/firmware.h>
-- 
1.6.5.2




