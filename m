From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/6] sky2: version 1.26
Date: Thu, 29 Oct 2009 09:37:10 -0700
Message-ID: <20091029163849.559930232@vyatta.com>
References: <20091029163704.793246334@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57324 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755508AbZJ2QjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 12:39:23 -0400
Content-Disposition: inline; filename=sky2-1.26.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-10-29 08:57:43.512001253 -0700
+++ b/drivers/net/sky2.c	2009-10-29 08:59:34.782375629 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.25"
+#define DRV_VERSION		"1.26"
 #define PFX			DRV_NAME " "
 
 /*

-- 

