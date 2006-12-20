From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 6/6] sky2: version 1.11
Date: Wed, 20 Dec 2006 13:06:38 -0800
Message-ID: <20061220210923.498124547@osdl.org>
References: <20061220210632.183204605@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58231 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423151AbWLVAkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 19:40:52 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-v1.11
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Version update

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- sky2-2.6.orig/drivers/net/sky2.c	2006-12-19 14:20:46.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2006-12-19 14:20:51.000000000 -0800
@@ -49,7 +49,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.10"
+#define DRV_VERSION		"1.11"
 #define PFX			DRV_NAME " "
 
 /*

--
Stephen Hemminger <shemminger@osdl.org>

