From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/4] r6040: bump release number to 0.20
Date: Wed, 7 Jan 2009 17:40:47 +0100
Message-ID: <200901071740.47164.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:38692 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbZAGQkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 11:40:52 -0500
Received: by bwz14 with SMTP id 14so25798863bwz.13
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2009 08:40:50 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/4] r6040: bump release number to 0.20

This patch bumps release number to 0.20 and 07Jan2009.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index ce619d3..706a0af 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.19"
-#define DRV_RELDATE	"18Dec2008"
+#define DRV_VERSION	"0.20"
+#define DRV_RELDATE	"07Jan2009"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
