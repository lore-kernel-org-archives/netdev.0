From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/6] sky2: version 1.14
Date: Wed, 11 Apr 2007 14:48:03 -0700
Message-ID: <20070411214900.251385599@linux-foundation.org>
References: <20070411214757.194710334@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34857 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030459AbXDKWah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 18:30:37 -0400
Content-Disposition: inline; filename=sky2-1.14.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-04-11 14:41:09.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-04-11 14:44:24.000000000 -0700
@@ -49,7 +49,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.13"
+#define DRV_VERSION		"1.14"
 #define PFX			DRV_NAME " "
 
 /*

--
Stephen Hemminger <shemminger@linux-foundation.org>

