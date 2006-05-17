From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] sky2 version 1.4
Date: Wed, 17 May 2006 14:37:07 -0700
Message-ID: <20060517213802.802477000@localhost.localdomain>
References: <20060517213702.322762000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46776 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751151AbWEQVlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 17:41:24 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-1.4.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to track impact of this group of changes.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-05-16 10:10:13.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-16 10:10:15.000000000 -0700
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.3"
+#define DRV_VERSION		"1.4"
 #define PFX			DRV_NAME " "
 
 /*

--

