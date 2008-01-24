From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [Patch 2.6.24 3/3]S2io: Version update for [Patch 2.6.24 1/3] &
 [Patch 2.6.24 2/3]
Date: Thu, 24 Jan 2008 13:11:09 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10801241308510.3800-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33750 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbYAXSLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 13:11:19 -0500
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

