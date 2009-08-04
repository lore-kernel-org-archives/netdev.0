From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 5/5] cpmac: bump version to 0.5.1
Date: Tue, 4 Aug 2009 22:53:00 +0200
Message-ID: <200908042253.00563.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:21974 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932545AbZHDUxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:53:02 -0400
Received: by ey-out-2122.google.com with SMTP id 9so46715eyd.37
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 13:53:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 12a521e..0ef7467 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -54,7 +54,7 @@ module_param(dumb_switch, int, 0444);
 MODULE_PARM_DESC(debug_level, "Number of NETIF_MSG bits to enable");
 MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 
-#define CPMAC_VERSION "0.5.0"
+#define CPMAC_VERSION "0.5.1"
 /* frame size + 802.1q tag */
 #define CPMAC_SKB_SIZE		(ETH_FRAME_LEN + 4)
 #define CPMAC_QUEUES	8
