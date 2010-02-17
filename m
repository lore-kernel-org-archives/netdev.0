From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 8/8] bnx2x: version number and date
Date: Wed, 17 Feb 2010 14:05:54 +0200
Message-ID: <1266408354.25691.855.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2994 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756814Ab0BQMNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 07:13:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated release version and date: 1.52.1-6 and 2010/02/16

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 164a5e8..32b629e 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -57,8 +57,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.52.1-5"
-#define DRV_MODULE_RELDATE	"2009/11/09"
+#define DRV_MODULE_VERSION	"1.52.1-6"
+#define DRV_MODULE_RELDATE	"2010/02/16"
 #define BNX2X_BC_VER		0x040200
 
 #include <linux/firmware.h>
-- 
1.6.3.3




