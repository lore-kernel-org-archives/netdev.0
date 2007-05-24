From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 7/7] sky2: version 1.15
Date: Thu, 24 May 2007 15:22:49 -0700
Message-ID: <20070524222538.900275086@linux-foundation.org>
References: <20070524222242.555399884@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:52105 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753025AbXEXWbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 18:31:00 -0400
Content-Disposition: inline; filename=sky2-1.15
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Why? Most bug reports on vendor kernels with backported
drivers.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/sky2.c	2007-05-24 11:20:26.000000000 -0700
+++ b/drivers/net/sky2.c	2007-05-24 11:20:29.000000000 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.14"
+#define DRV_VERSION		"1.15"
 #define PFX			DRV_NAME " "
 
 /*

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

