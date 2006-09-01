From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] skge: version 1.8
Date: Fri, 01 Sep 2006 15:53:50 -0700
Message-ID: <20060901225449.647481282@zqx3.pdx.osdl.net>
References: <20060901225346.750571061@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13967 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751181AbWIAW6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:58:16 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-1.8.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because of the NAPI and other SMP fixes, let's call
this a version.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -43,7 +43,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.7"
+#define DRV_VERSION		"1.8"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128

--


-- 
VGER BF report: H 0.0441835
