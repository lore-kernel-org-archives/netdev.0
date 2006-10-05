From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/4] skge: version 1.9
Date: Thu, 05 Oct 2006 15:49:53 -0700
Message-ID: <20061005225209.769741968@osdl.org>
References: <20061005224949.456192755@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4304 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932420AbWJEXzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 19:55:18 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-v1.9.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Want to be able to track downstream impact of fiber related
fixes.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.orig/drivers/net/skge.c
+++ linux-2.6/drivers/net/skge.c
@@ -43,7 +43,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.8"
+#define DRV_VERSION		"1.9"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128

--
Stephen Hemminger <shemminger@osdl.org>

