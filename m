From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 9/9] sky2: version 1.24
Date: Fri, 14 Aug 2009 08:15:20 -0700
Message-ID: <20090814151608.604253107@vyatta.com>
References: <20090814151511.992669598@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44120 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932533AbZHNPTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 11:19:51 -0400
Content-Disposition: inline; filename=sky2-v1.24.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-08-14 07:58:50.471356910 -0700
+++ b/drivers/net/sky2.c	2009-08-14 07:58:51.564040271 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.23"
+#define DRV_VERSION		"1.24"
 #define PFX			DRV_NAME " "
 
 /*

-- 

