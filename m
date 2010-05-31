From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/2] r6040: bump version to 0.26 and date to 30 May 2010
Date: Mon, 31 May 2010 21:19:04 +0200
Message-ID: <201005312119.04553.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:42108 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756998Ab0EaTTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 15:19:06 -0400
Received: by mail-ww0-f46.google.com with SMTP id 28so1478132wwb.19
        for <netdev@vger.kernel.org>; Mon, 31 May 2010 12:19:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 6878511..7d482a2 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.25"
-#define DRV_RELDATE	"20Aug2009"
+#define DRV_VERSION	"0.26"
+#define DRV_RELDATE	"30May2010"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
-- 
1.7.1

