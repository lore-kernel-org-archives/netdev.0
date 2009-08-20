From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/3] r6040: bump to version 0.25 and 20 August 2009 release date
Date: Thu, 20 Aug 2009 13:26:23 +0200
Message-ID: <200908201326.23859.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mark@bifferos.com,
	bifferos <bifferos@yahoo.co.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:39465 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbZHTL0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 07:26:25 -0400
Received: by mail-fx0-f217.google.com with SMTP id 17so380883fxm.37
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 04:26:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 7238a6f..8068a07 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -49,8 +49,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.24"
-#define DRV_RELDATE	"08Jul2009"
+#define DRV_VERSION	"0.25"
+#define DRV_RELDATE	"20Aug2009"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
