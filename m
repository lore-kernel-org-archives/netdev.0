From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] skge: version 1.10
Date: Fri, 02 Feb 2007 08:22:54 -0800
Message-ID: <20070202162419.363363000@linux-foundation.org>
References: <20070202162250.980620000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56748 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945973AbXBBQZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 11:25:34 -0500
Content-Disposition: inline; filename=skge-1.10
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark this as 1.10 because WOL now works

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- skge.orig/drivers/net/skge.c
+++ skge/drivers/net/skge.c
@@ -42,7 +42,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.9"
+#define DRV_VERSION		"1.10"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128

-- 

