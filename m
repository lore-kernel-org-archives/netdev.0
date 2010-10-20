From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/2] r6040: bump to version 0.27 and release date of 20Oct2010
Date: Wed, 20 Oct 2010 23:09:46 +0200
Message-ID: <201010202309.47662.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:55473 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249Ab0JTVHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 17:07:49 -0400
Received: by ewy20 with SMTP id 20so5110577ewy.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 14:07:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 3843363..7294cec 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.26"
-#define DRV_RELDATE	"30May2010"
+#define DRV_VERSION	"0.27"
+#define DRV_RELDATE	"20Oct2010"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */


