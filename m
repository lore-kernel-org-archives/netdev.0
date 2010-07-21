From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 3/3 net-2.6] bnx2x: Advance a module version
Date: Wed, 21 Jul 2010 18:59:17 +0300
Message-ID: <1279727957.14094.44.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2038 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755858Ab0GUP7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 11:59:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Advance a module version to 1.52.53-2.

 Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
 Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
 Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index b86e47b..46167c0 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -57,8 +57,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.52.53-1"
-#define DRV_MODULE_RELDATE	"2010/18/04"
+#define DRV_MODULE_VERSION	"1.52.53-2"
+#define DRV_MODULE_RELDATE	"2010/21/07"
 #define BNX2X_BC_VER		0x040200
 
 #include <linux/firmware.h>
-- 
1.7.1




