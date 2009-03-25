From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/2] Bump release date to 25Mar2009 and version to 0.22
Date: Wed, 25 Mar 2009 10:34:38 +0100
Message-ID: <200903251034.39075.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:47677 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187AbZCYJeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 05:34:46 -0400
Received: by yx-out-2324.google.com with SMTP id 31so2947518yxl.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 02:34:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch bumps the driver release date to March 25th 2009
and release version to 0.22.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index d3458ef..0a37f99 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.21"
-#define DRV_RELDATE	"09Jan2009"
+#define DRV_VERSION	"0.22"
+#define DRV_RELDATE	"25Mar2009"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
