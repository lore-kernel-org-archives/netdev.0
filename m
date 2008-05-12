From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.26 3/3]S2io: Version update for napi and MSI-X patches
Date: Mon, 12 May 2008 13:43:05 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10805121342210.18446-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:41305 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbYELRnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 13:43:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Updated version number

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.24-P2/drivers/net/s2io.c 2.0.26.24-P3/drivers/net/s2io.c
--- 2.0.26.24-P2/drivers/net/s2io.c	2008-05-08 15:37:57.000000000 -0700
+++ 2.0.26.24-P3/drivers/net/s2io.c	2008-05-08 15:39:46.000000000 -0700
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.23"
+#define DRV_VERSION "2.0.26.24"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";

