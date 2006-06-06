From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] skge: version 1.6
Date: Tue, 06 Jun 2006 10:11:15 -0700
Message-ID: <20060606171342.598475000@zqx3.pdx.osdl.net>
References: <20060606171110.592587000@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:211 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750938AbWFFRPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 13:15:39 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-1.6.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update version string.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -44,7 +44,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.5"
+#define DRV_VERSION		"1.6"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128

--

