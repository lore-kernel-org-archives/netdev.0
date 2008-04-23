From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.26 5/5]S2io: Version update for multi ring related patches
Date: Wed, 23 Apr 2008 13:35:02 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10804231333480.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39525 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbYDWRfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:35:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Updated version number.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -Nurp 2-0-26-21-4/drivers/net/s2io.c 2-0-26-21-5/drivers/net/s2io.c
--- 2-0-26-21-4/drivers/net/s2io.c	2008-04-09 21:09:17.000000000 +0530
+++ 2-0-26-21-5/drivers/net/s2io.c	2008-04-09 21:10:14.000000000 +0530
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.19"
+#define DRV_VERSION "2.0.26.21"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";

