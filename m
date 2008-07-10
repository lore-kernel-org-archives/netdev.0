From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 3/3]S2io: Version update for IOMMU overflow checking and
 enable msi-x link interrupts patches.
Date: Wed, 9 Jul 2008 23:50:13 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10807092349230.5252-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37597 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbYGJEJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 00:09:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Updated version number

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.25P2/drivers/net/s2io.c 2.0.26.25P3/drivers/net/s2io.c
--- 2.0.26.25P2/drivers/net/s2io.c	2008-06-27 13:30:06.000000000 -0700
+++ 2.0.26.25P3/drivers/net/s2io.c	2008-06-27 13:30:33.000000000 -0700
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.24"
+#define DRV_VERSION "2.0.26.25"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";

