From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 8/8] bnx2x: Update to version 1.52.1-1
Date: Thu, 15 Oct 2009 08:48:50 +0200
Message-ID: <1255589330.25030.78.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4643 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934580AbZJOGtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 02:49:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ba131f4..59b58d8 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -56,8 +56,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.52.1"
-#define DRV_MODULE_RELDATE	"2009/08/12"
+#define DRV_MODULE_VERSION	"1.52.1-1"
+#define DRV_MODULE_RELDATE	"2009/10/13"
 #define BNX2X_BC_VER		0x040200
 
 #include <linux/firmware.h>
-- 
1.5.4.3




