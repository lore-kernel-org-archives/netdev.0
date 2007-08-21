From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/3] sky2 1.17
Date: Tue, 21 Aug 2007 14:34:04 -0700
Message-ID: <20070821213456.686991934@linux-foundation.org>
References: <20070821213401.543412708@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarxik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50901 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753366AbXHUViJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 17:38:09 -0400
Content-Disposition: inline; filename=sky2-1.17
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark new version to track if current driver is in use.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-08-21 10:36:58.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-21 10:44:22.000000000 -0700
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.16"
+#define DRV_VERSION		"1.17"
 #define PFX			DRV_NAME " "
 
 /*

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

