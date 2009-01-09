From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/4] r6040: bump release to 0.21
Date: Fri, 9 Jan 2009 02:04:57 +0100
Message-ID: <200901090204.57238.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:32932 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbZAIBFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 20:05:01 -0500
Received: by mail-bw0-f21.google.com with SMTP id 14so28273359bwz.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 17:05:00 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/4] r6040: bump release to 0.21

Bump version to 0.21 and release date to 09Jan2009.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 21d830b..0e4199b 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.20"
-#define DRV_RELDATE	"07Jan2009"
+#define DRV_VERSION	"0.21"
+#define DRV_RELDATE	"09Jan2009"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
