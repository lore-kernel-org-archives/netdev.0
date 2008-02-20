From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [Patch 2.6.25 4/4]S2io: Version update for multiqueue and vlan
 patches
Date: Wed, 20 Feb 2008 17:10:28 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10802201709170.11320-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55750 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759493AbYBTWKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 17:10:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Updated version number.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-19-1/drivers/net/s2io.c 2-0-26-19-2/drivers/net/s2io.c
--- 2-0-26-19-1/drivers/net/s2io.c	2008-02-15 07:03:10.000000000 +0530
+++ 2-0-26-19-2/drivers/net/s2io.c	2008-02-15 07:04:09.000000000 +0530
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.15-2"
+#define DRV_VERSION "2.0.26.19"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";

