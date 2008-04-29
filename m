From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.26 2/2]S2io: Version update for multi ring patche
Date: Mon, 28 Apr 2008 21:09:40 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10804282108480.22468-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:58397 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbYD2BJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 21:09:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Updated version number.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -pNur 2.6.26_version_test1/drivers/net/s2io.c 2.6.26_version_test2/drivers/net/s2io.c
--- 2.6.26_version_test1/drivers/net/s2io.c	2008-04-25 19:54:30.000000000 -0700
+++ 2.6.26_version_test2/drivers/net/s2io.c	2008-04-25 20:03:05.000000000 -0700
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.22"
+#define DRV_VERSION "2.0.26.23"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";

