From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 10/10] sky2: version 1.9
Date: Wed, 11 Oct 2006 14:22:35 -0700
Message-ID: <20061011212311.715010657@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15053 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161490AbWJKVZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:25:55 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-1.10.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark version, this has been a lot of patches.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-10-11 14:19:14.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-11 14:19:23.000000000 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.9"
+#define DRV_VERSION		"1.10"
 #define PFX			DRV_NAME " "
 
 /*

--
Stephen Hemminger <shemminger@osdl.org>

