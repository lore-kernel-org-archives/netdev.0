From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 13/13] bnx2x: Date and version
Date: Sun, 18 Apr 2010 17:51:20 +0300
Message-ID: <1271602280.27235.204.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2016 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755609Ab0DROv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 10:51:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set version to 1.52.53-1.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a0e01bc..42d5af4 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -61,8 +61,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.52.1-8"
-#define DRV_MODULE_RELDATE	"2010/04/01"
+#define DRV_MODULE_VERSION	"1.52.53-1"
+#define DRV_MODULE_RELDATE	"2010/18/04"
 #define BNX2X_BC_VER		0x040200
 
 #include <linux/firmware.h>
-- 
1.7.0.4




