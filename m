From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/10] sky2: version 1.27
Date: Fri, 12 Feb 2010 08:58:07 -0800
Message-ID: <20100212165938.213552895@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49515 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757444Ab0BLRIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:08:40 -0500
Content-Disposition: inline; filename=sky2-1.27.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-02-11 09:07:28.062232424 -0800
+++ b/drivers/net/sky2.c	2010-02-11 09:07:39.572090343 -0800
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.26"
+#define DRV_VERSION		"1.27"
 #define PFX			DRV_NAME " "
 
 /*

-- 

