From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/6] sky2: version 1.30
Date: Wed, 16 Nov 2011 15:43:00 -0800
Message-ID: <20111116234345.005320568@vyatta.com>
References: <20111116234254.319625694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:41565 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754574Ab1KPX5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 18:57:33 -0500
Content-Disposition: inline; filename=sky2-1.30-version.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update version number.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:08:36.031104340 -0800
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:11:24.728913165 -0800
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.29"
+#define DRV_VERSION		"1.30"
 
 /*
  * The Yukon II chipset takes 64 bit command blocks (called list elements)
