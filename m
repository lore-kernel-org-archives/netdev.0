From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] skge: version 1.7
Date: Mon, 28 Aug 2006 16:19:39 -0700
Message-ID: <20060828232038.693682014@localhost.localdomain>
References: <20060828231934.477469235@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47750 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964890AbWH1XbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 19:31:22 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-vers.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Increase version.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -43,7 +43,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.6"
+#define DRV_VERSION		"1.7"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128

--
Stephen Hemminger <shemminger@osdl.org>

