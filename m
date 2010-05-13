From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/6] sky2: version 1.28
Date: Thu, 13 May 2010 09:12:53 -0700
Message-ID: <20100513161351.427867794@vyatta.com>
References: <20100513161247.833356588@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39379 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757301Ab0EMXaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 19:30:25 -0400
Content-Disposition: inline; filename=sky2-1.28.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 1.28

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-05-13 09:11:26.947584759 -0700
+++ b/drivers/net/sky2.c	2010-05-13 09:11:35.827269492 -0700
@@ -53,7 +53,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.27"
+#define DRV_VERSION		"1.28"
 
 /*
  * The Yukon II chipset takes 64 bit command blocks (called list elements)


