From: shemminger@linux-foundation.org
Subject: [PATCH 5/5] sky2: version 1.11.1
Date: Fri, 26 Jan 2007 11:38:40 -0800
Message-ID: <20070126194004.370416000@linux-foundation.org>
References: <20070126193835.658962000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52036 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131AbXAZToq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 14:44:46 -0500
Content-Disposition: inline; filename=sky2-v1.11
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Version update to 1.11.1.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- sky2-2.6.orig/drivers/net/sky2.c	2007-01-26 11:27:42.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2007-01-26 11:27:45.000000000 -0800
@@ -49,7 +49,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.10"
+#define DRV_VERSION		"1.11.1"
 #define PFX			DRV_NAME " "
 
 /*

--
Stephen Hemminger <shemminger@linux-foundation.org>

