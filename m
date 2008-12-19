From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/3] r6040: bump release number to 0.19
Date: Fri, 19 Dec 2008 11:02:23 +0100
Message-ID: <200812191102.23897.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	Joe Chou <Joe.Chou@rdc.com.tw>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:32973 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbYLSKC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 05:02:26 -0500
Received: by fg-out-1718.google.com with SMTP id 19so349619fgg.17
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2008 02:02:25 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/3] r6040: bump release number to 0.19

This patch bumps the release number of the driver.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 1117ffa..9d2de32 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.18"
-#define DRV_RELDATE	"13Jul2008"
+#define DRV_VERSION	"0.19"
+#define DRV_RELDATE	"18Dec2008"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
