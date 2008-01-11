From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] sky2: version 1.21
Date: Thu, 10 Jan 2008 16:14:15 -0800
Message-ID: <20080111001550.988424365@linux-foundation.org>
References: <20080111001411.158113585@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60437 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752803AbYAKDQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 22:16:54 -0500
Content-Disposition: inline; filename=sky2-1.21
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update driver version reflects new hardware support.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
Please add to staging tree for 2.6.25.

--- a/drivers/net/sky2.c	2008-01-10 15:49:27.000000000 -0800
+++ b/drivers/net/sky2.c	2008-01-10 15:49:29.000000000 -0800
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.20"
+#define DRV_VERSION		"1.21"
 #define PFX			DRV_NAME " "
 
 /*

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

