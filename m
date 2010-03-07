From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/3] cpmac: bump version to 0.5.2
Date: Sun, 7 Mar 2010 11:55:50 +0100
Message-ID: <201003071155.51795.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:63171 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab0CGKzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 05:55:54 -0500
Received: by mail-bw0-f222.google.com with SMTP id 22so2144929bwz.28
        for <netdev@vger.kernel.org>; Sun, 07 Mar 2010 02:55:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 4051e81..97b8890 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -56,7 +56,7 @@ module_param(dumb_switch, int, 0444);
 MODULE_PARM_DESC(debug_level, "Number of NETIF_MSG bits to enable");
 MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 
-#define CPMAC_VERSION "0.5.1"
+#define CPMAC_VERSION "0.5.2"
 /* frame size + 802.1q tag + FCS size */
 #define CPMAC_SKB_SIZE		(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
 #define CPMAC_QUEUES	8

