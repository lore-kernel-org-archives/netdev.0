From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/7] au1000-eth: set MODULE_VERSION
Date: Wed, 7 Apr 2010 10:08:57 +0200
Message-ID: <201004071008.57246.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:51097 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982Ab0DGIKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 04:10:04 -0400
Received: by ey-out-2122.google.com with SMTP id d26so91625eyd.19
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 01:10:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 2963159..b96abc5 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -83,6 +83,7 @@ static int au1000_debug = 3;
 MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_DESCRIPTION(DRV_DESC);
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 /*
  * Theory of operation
