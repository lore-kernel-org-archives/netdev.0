From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [Patch 2.6.25 1/1]S2io: Version update for Tx completion patch
Date: Fri, 28 Mar 2008 17:35:36 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10803281730500.11037-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55334 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbYC1Vfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:35:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Updated version number.
- Resubmitting with correct version update.
- this patch to be applied for upstream-davem branch

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -Nurp 2-0-26-21-1/drivers/net/s2io.c 2-0-26-21-2/drivers/net/s2io.c
--- 2-0-26-21-1/drivers/net/s2io.c	2008-03-20 10:22:25.000000000 +0530
+++ 2-0-26-21-2/drivers/net/s2io.c	2008-03-20 10:36:33.000000000 +0530
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.15-2"
+#define DRV_VERSION "2.0.26.20"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";

