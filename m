From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.25 2/2]S2io: Version update for memory leak fix during
 free_tx_buffers
Date: Wed, 23 Apr 2008 13:28:58 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10804231328110.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39389 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbYDWR3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:29:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Updated version number.

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.22-1/drivers/net/s2io.c 2.0.26.22-2/drivers/net/s2io.c
--- 2.0.26.22-1/drivers/net/s2io.c	2008-04-22 15:12:25.000000000 -0700
+++ 2.0.26.22-2/drivers/net/s2io.c	2008-04-22 15:12:03.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.20"
+#define DRV_VERSION "2.0.26.22"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";


