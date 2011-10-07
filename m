From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/2 net] r6040: bump version to 0.28 and date to 07Oct2011.
Date: Fri, 7 Oct 2011 11:41:10 +0200
Message-ID: <201110071141.10449.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64902 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030Ab1JGJlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 05:41:16 -0400
Received: by wwf22 with SMTP id 22so5632489wwf.1
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 02:41:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
CC: stable@kernel.org # 2.6.38+
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index ab59538..6b21565 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.27"
-#define DRV_RELDATE	"23Feb2011"
+#define DRV_VERSION	"0.28"
+#define DRV_RELDATE	"07Oct2011"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
-- 
1.7.4.1
