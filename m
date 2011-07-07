From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 4/5] sky2: version 1.29
Date: Thu, 07 Jul 2011 08:51:00 -0700
Message-ID: <20110707155212.263256640@vyatta.com>
References: <20110707155056.939223264@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:56590 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842Ab1GGQnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 12:43:43 -0400
Content-Disposition: inline; filename=sky2-version.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since new hardware chip support was added bump version.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2011-07-07 08:38:11.208009500 -0700
+++ b/drivers/net/sky2.c	2011-07-07 08:38:21.612001463 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.28"
+#define DRV_VERSION		"1.29"
 
 /*
  * The Yukon II chipset takes 64 bit command blocks (called list elements)


