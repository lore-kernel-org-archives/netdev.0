From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/6] sky2: v1.13
Date: Thu, 15 Feb 2007 16:40:35 -0800
Message-ID: <20070216004142.557477000@linux-foundation.org>
References: <20070216004028.943889000@linux-foundation.org>
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40587 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422935AbXBPAn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 19:43:29 -0500
Content-Disposition: inline; filename=sky2-v1.13
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New version.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-15 15:00:38.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-15 15:00:56.000000000 -0800
@@ -49,7 +49,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.12"
+#define DRV_VERSION		"1.13"
 #define PFX			DRV_NAME " "
 
 /*

--
Stephen Hemminger <shemminger@linux-foundation.org>

