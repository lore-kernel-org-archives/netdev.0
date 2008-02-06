From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.25 3/3]S2io: Vesrion update for Multiqueue patches
Date: Wed, 6 Feb 2008 15:27:31 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10802061526440.18812-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55373 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757520AbYBFU1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 15:27:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Updated version number

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-16-2/drivers/net/s2io.c 2-0-26-16-3/drivers/net/s2io.c
--- 2-0-26-16-2/drivers/net/s2io.c	2008-01-31 16:40:10.000000000 +0530
+++ 2-0-26-16-3/drivers/net/s2io.c	2008-01-31 16:40:42.000000000 +0530
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.15-2"
+#define DRV_VERSION "2.0.26.16"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";

