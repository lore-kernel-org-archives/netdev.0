From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 4/4] vxge: Version update.
Date: Thu, 8 Apr 2010 04:45:07 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.11004080444280.365-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:38595 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab0DHIpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 04:45:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Version update.
 
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>
---
diff -urpN patch3/drivers/net/vxge/vxge-version.h patch4/drivers/net/vxge/vxge-version.h
--- patch3/drivers/net/vxge/vxge-version.h	2010-04-01 12:13:17.000000000 +0530
+++ patch4/drivers/net/vxge/vxge-version.h	2010-04-07 11:39:50.000000000 +0530
@@ -17,7 +17,7 @@
 
 #define VXGE_VERSION_MAJOR	"2"
 #define VXGE_VERSION_MINOR	"0"
-#define VXGE_VERSION_FIX	"7"
-#define VXGE_VERSION_BUILD	"20144"
+#define VXGE_VERSION_FIX	"8"
+#define VXGE_VERSION_BUILD	"20182"
 #define VXGE_VERSION_FOR	"k"
 #endif

