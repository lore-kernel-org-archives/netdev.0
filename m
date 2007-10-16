From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 7/7] skge 1.12
Date: Tue, 16 Oct 2007 12:15:55 -0700
Message-ID: <20071016191734.231911344@linux-foundation.org>
References: <20071016191548.447710749@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33004 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765400AbXJPTT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 15:19:28 -0400
Content-Disposition: inline; filename=skge-1.12
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

version update

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/skge.c	2007-10-16 10:57:42.000000000 -0700
+++ b/drivers/net/skge.c	2007-10-16 10:57:50.000000000 -0700
@@ -44,7 +44,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.11"
+#define DRV_VERSION		"1.12"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

