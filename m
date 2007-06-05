From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 7/7] sky2: version 1.15
Date: Mon, 04 Jun 2007 17:23:27 -0700
Message-ID: <20070605002739.135071963@linux-foundation.org>
References: <20070605002320.868185090@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55511 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759322AbXFEAnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 20:43:22 -0400
Content-Disposition: inline; filename=sky2-1.15
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New version because of new chip support.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/sky2.c	2007-05-31 11:27:07.000000000 -0700
+++ b/drivers/net/sky2.c	2007-05-31 11:27:08.000000000 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.14"
+#define DRV_VERSION		"1.15"
 #define PFX			DRV_NAME " "
 
 /*

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

