From: shemminger@osdl.org
Subject: [PATCH 9/9] sky2: version 1.7
Date: Mon, 28 Aug 2006 10:00:53 -0700
Message-ID: <20060828170221.556313934@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44162 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751269AbWH1SQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:16:40 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-1.7.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change version number for this bundle.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-08-22 14:55:42.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-22 14:55:46.000000000 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.6"
+#define DRV_VERSION		"1.7"
 #define PFX			DRV_NAME " "
 
 /*

--
Stephen Hemminger <shemminger@osdl.org>


