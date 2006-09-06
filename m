From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 6/6] sky2: version 1.6.1
Date: Wed, 06 Sep 2006 10:17:58 -0700
Message-ID: <20060906171922.357072000@localhost.localdomain>
References: <20060906171752.781595000@localhost.localdomain>
Cc: stable@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40871 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751471AbWIFSLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 14:11:32 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-dotvers.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since this code incorporates some of the fixes from 2.6.18, change
the version number.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- linux-2.6.17.11.orig/drivers/net/sky2.c	2006-09-06 09:29:23.000000000 -0700
+++ linux-2.6.17.11/drivers/net/sky2.c	2006-09-06 09:29:30.000000000 -0700
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.4"
+#define DRV_VERSION		"1.6.1"
 #define PFX			DRV_NAME " "
 
 /*

--
Stephen Hemminger <shemminger@osdl.org>

