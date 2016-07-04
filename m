From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 8/9] net: r6040: Update my email
Date: Mon,  4 Jul 2016 14:36:08 -0700
Message-ID: <1467668169-31547-9-git-send-email-f.fainelli@gmail.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34083 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932596AbcGDVgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:21 -0400
Received: by mail-oi0-f65.google.com with SMTP id s17so24991632oih.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:21 -0700 (PDT)
In-Reply-To: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update my email address in the driver and MAINTAINERS file.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS                      | 2 +-
 drivers/net/ethernet/rdc/r6040.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 772c9ffa2272..bf889d5e45a0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9558,7 +9558,7 @@ M:	Florian Fainelli <florian@openwrt.org>
 S:	Maintained
 
 RDC R6040 FAST ETHERNET DRIVER
-M:	Florian Fainelli <florian@openwrt.org>
+M:	Florian Fainelli <f.fainelli@gmail.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/ethernet/rdc/r6040.c
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index c0256b865ff9..c8985cfbe2da 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -4,7 +4,7 @@
  * Copyright (C) 2004 Sten Wang <sten.wang@rdc.com.tw>
  * Copyright (C) 2007
  *	Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
- * Copyright (C) 2007-2012 Florian Fainelli <florian@openwrt.org>
+ * Copyright (C) 2007-2012 Florian Fainelli <f.fainelli@gmail.com>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -162,7 +162,7 @@
 
 MODULE_AUTHOR("Sten Wang <sten.wang@rdc.com.tw>,"
 	"Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>,"
-	"Florian Fainelli <florian@openwrt.org>");
+	"Florian Fainelli <f.fainelli@gmail.com>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("RDC R6040 NAPI PCI FastEthernet driver");
 MODULE_VERSION(DRV_VERSION " " DRV_RELDATE);
-- 
2.7.4
