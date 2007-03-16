From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 7/7] skge: version 1.11
Date: Fri, 16 Mar 2007 14:01:32 -0700
Message-ID: <20070316210156.269925069@linux-foundation.org>
References: <20070316210125.324052637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36173 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965938AbXCPVGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 17:06:41 -0400
Content-Disposition: inline; filename=skge-1.11
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New version to track changes.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- skge-dev.orig/drivers/net/skge.c
+++ skge-dev/drivers/net/skge.c
@@ -42,7 +42,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.10"
+#define DRV_VERSION		"1.11"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128

-- 

