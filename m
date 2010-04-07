From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 7/7] au1000-eth: bump to 1.7
Date: Wed, 7 Apr 2010 10:09:20 +0200
Message-ID: <201004071009.20700.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:51097 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932269Ab0DGIK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 04:10:26 -0400
Received: by ey-out-2122.google.com with SMTP id d26so91625eyd.19
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 01:10:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 5afca6c..7abb2c8 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -80,7 +80,7 @@ static int au1000_debug = 3;
 				NETIF_MSG_LINK)
 
 #define DRV_NAME	"au1000_eth"
-#define DRV_VERSION	"1.6"
+#define DRV_VERSION	"1.7"
 #define DRV_AUTHOR	"Pete Popov <ppopov@embeddedalley.com>"
 #define DRV_DESC	"Au1xxx on-chip Ethernet driver"
 
