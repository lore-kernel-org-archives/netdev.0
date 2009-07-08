From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/2] r6040: bump driver version to 0.24 and date to 08 July 2009
Date: Wed, 8 Jul 2009 15:05:48 +0200
Message-ID: <200907081505.48403.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:41673 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbZGHNFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 09:05:55 -0400
Received: by ewy26 with SMTP id 26so1567305ewy.37
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2009 06:05:52 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index e532be4..7664d40 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.23"
-#define DRV_RELDATE	"05May2009"
+#define DRV_VERSION	"0.24"
+#define DRV_RELDATE	"08Jul2009"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
