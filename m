From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [Patch 2.6.24 3/3]S2io: Version update for vlan and LRO patches
Date: Wed, 6 Feb 2008 15:30:19 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10802061529390.18812-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55472 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756498AbYBFUaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 15:30:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Updated version number.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-18-2/drivers/net/s2io.c 2-0-26-18-3/drivers/net/s2io.c
--- 2-0-26-18-2/drivers/net/s2io.c	2008-01-24 04:27:23.000000000 +0530
+++ 2-0-26-18-3/drivers/net/s2io.c	2008-01-24 04:39:07.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.17"
+#define DRV_VERSION "2.0.26.18"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";

