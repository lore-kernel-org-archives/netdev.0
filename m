From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/6] sky2: email and version change.
Date: Fri, 23 Feb 2007 15:10:48 -0800
Message-ID: <20070223231353.808600000@linux-foundation.org>
References: <20070223231042.860031000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40980 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933270AbXBWXRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 18:17:34 -0500
Content-Disposition: inline; filename=sky2-copyright.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Put in new email address.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.16.y.orig/drivers/net/sky2.c	2007-02-23 14:45:42.000000000 -0800
+++ linux-2.6.16.y/drivers/net/sky2.c	2007-02-23 14:45:44.000000000 -0800
@@ -6,7 +6,7 @@
  * of the original driver such as link fail-over and link management because
  * those should be done at higher levels.
  *
- * Copyright (C) 2005 Stephen Hemminger <shemminger@osdl.org>
+ * Copyright (C) 2005 Stephen Hemminger <shemminger@linux-foundation.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"0.15"
+#define DRV_VERSION		"0.15.1"
 #define PFX			DRV_NAME " "
 
 /*
@@ -3481,6 +3481,6 @@
 module_exit(sky2_cleanup_module);
 
 MODULE_DESCRIPTION("Marvell Yukon 2 Gigabit Ethernet driver");
-MODULE_AUTHOR("Stephen Hemminger <shemminger@osdl.org>");
+MODULE_AUTHOR("Stephen Hemminger <shemminger@linux-foundation.org>");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);

--
Stephen Hemminger <shemminger@linux-foundation.org>

