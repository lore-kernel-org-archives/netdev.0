From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/6] skge version 1.13
Date: Mon, 26 Nov 2007 11:54:53 -0800
Message-ID: <20071126195557.815206367@linux-foundation.org>
References: <20071126195447.846382144@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39948 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753958AbXKZT6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 14:58:52 -0500
Content-Disposition: inline; filename=skge-vers.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Version for 2.6.24

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/skge.c	2007-11-21 14:07:37.000000000 -0800
+++ b/drivers/net/skge.c	2007-11-21 14:08:35.000000000 -0800
@@ -44,7 +44,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.12"
+#define DRV_VERSION		"1.13"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

