From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/7] sky2: version 1.25
Date: Tue, 18 Aug 2009 18:17:11 -0700
Message-ID: <20090819011739.071887884@vyatta.com>
References: <20090819011704.685802801@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:50673 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181AbZHSBWq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 21:22:46 -0400
Content-Disposition: inline; filename=sky2-1.25.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-08-18 17:53:33.772652966 -0700
+++ b/drivers/net/sky2.c	2009-08-18 17:53:42.177674500 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.24"
+#define DRV_VERSION		"1.25"
 #define PFX			DRV_NAME " "
 
 /*

-- 

