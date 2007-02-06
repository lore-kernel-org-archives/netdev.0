From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 7/7] sky2: version 1.12
Date: Tue, 06 Feb 2007 10:45:45 -0800
Message-ID: <20070206184855.429854000@linux-foundation.org>
References: <20070206184538.675048000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45585 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933200AbXBFSxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 13:53:07 -0500
Content-Disposition: inline; filename=sky2-1.12
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated version for WOL and new id's

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-06 10:44:29.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-06 10:44:31.000000000 -0800
@@ -49,7 +49,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.11.1"
+#define DRV_VERSION		"1.12"
 #define PFX			DRV_NAME " "
 
 /*

--
Stephen Hemminger <shemminger@linux-foundation.org>

