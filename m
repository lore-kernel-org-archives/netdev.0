From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 9/9] sky2: version 1.23
Date: Wed, 17 Jun 2009 10:30:40 -0700
Message-ID: <20090617173140.393319604@vyatta.com>
References: <20090617173031.703636683@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45315 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758030AbZFQReD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 13:34:03 -0400
Content-Disposition: inline; filename=sky2-vers.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version bump.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-06-17 10:29:59.249757381 -0700
+++ b/drivers/net/sky2.c	2009-06-17 10:30:00.319061538 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.22"
+#define DRV_VERSION		"1.23"
 #define PFX			DRV_NAME " "
 
 /*

-- 

