From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/5] sky2: version 1.22
Date: Tue, 17 Jun 2008 09:04:28 -0700
Message-ID: <20080617160503.701450382@vyatta.com>
References: <20080617160423.205070938@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:50959 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752147AbYFQQHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 12:07:44 -0400
Content-Disposition: inline; filename=sky2-1.22
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New version to reflect new hardware support

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2008-06-16 09:38:36.000000000 -0700
+++ b/drivers/net/sky2.c	2008-06-16 09:38:37.000000000 -0700
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.21"
+#define DRV_VERSION		"1.22"
 #define PFX			DRV_NAME " "
 
 /*

-- 

