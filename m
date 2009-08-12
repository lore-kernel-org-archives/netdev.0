From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 36/36] bnx2x: update version to 1.52.1
Date: Wed, 12 Aug 2009 21:24:31 +0300
Message-ID: <1250101471.27379.188.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4119 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753625AbZHLSZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:25:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 54e3ef9..037d862 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -56,8 +56,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.48.114-1"
-#define DRV_MODULE_RELDATE	"2009/07/29"
+#define DRV_MODULE_VERSION	"1.52.1"
+#define DRV_MODULE_RELDATE	"2009/08/12"
 #define BNX2X_BC_VER		0x040200
 
 #include <linux/firmware.h>
-- 
1.5.4.3




