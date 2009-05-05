From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/2] r6040: bump version to 0.23 and date to 05May2009
Date: Tue, 5 May 2009 08:30:45 +0200
Message-ID: <200905050830.45642.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f224.google.com ([209.85.219.224]:46878 "EHLO
	mail-ew0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbZEEGas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 02:30:48 -0400
Received: by ewy24 with SMTP id 24so4658005ewy.37
        for <netdev@vger.kernel.org>; Mon, 04 May 2009 23:30:48 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bump version to 0.23 and date to 05May2009.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index b75b047..d4ab162 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.22"
-#define DRV_RELDATE	"25Mar2009"
+#define DRV_VERSION	"0.23"
+#define DRV_RELDATE	"05May2009"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
