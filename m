From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/2 net-2.6] r6040: bump to version 0.27 and date 23Feb2011
Date: Mon, 7 Mar 2011 11:09:42 +0100
Message-ID: <201103071109.42377.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52910 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896Ab1CGKH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 05:07:58 -0500
Received: by wyg36 with SMTP id 36so3969679wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 02:07:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 7965ae4..e3ebd90 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>

 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.26"
-#define DRV_RELDATE	"30May2010"
+#define DRV_VERSION	"0.27"
+#define DRV_RELDATE	"23Feb2011"

 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
--
1.7.1

