From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] sky2: version 1.2
Date: Tue, 25 Apr 2006 10:58:54 -0700
Message-ID: <20060425175952.429830000@localhost.localdomain>
References: <20060425175849.372221000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28289 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932304AbWDYVCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 17:02:35 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-1.2.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update to version 1.2

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2-2.6.17.orig/drivers/net/sky2.c	2006-04-25 10:54:57.000000000 -0700
+++ sky2-2.6.17/drivers/net/sky2.c	2006-04-25 10:55:51.000000000 -0700
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.1"
+#define DRV_VERSION		"1.2"
 #define PFX			DRV_NAME " "
 
 /*

--

