From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 17/17] sky2: version 1.15
Date: Tue, 08 May 2007 20:50:06 -0700
Message-ID: <20070509035031.374634924@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:43668 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966275AbXEIEIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:08:53 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-1.15
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update version to match changes

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 15:37:19.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 15:37:24.000000000 -0700
@@ -52,7 +52,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.14"
+#define DRV_VERSION		"1.15"
 #define PFX			DRV_NAME " "
 
 /*

--

