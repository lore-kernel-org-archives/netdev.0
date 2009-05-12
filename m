From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH v2 2/7] [PATCH 2/8] can: Update MAINTAINERS and CREDITS file
Date: Tue, 12 May 2009 11:27:59 +0200
Message-ID: <20090512092757.435595815@denx.de>
References: <20090512092757.048938233@denx.de>
Cc: linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:34786 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756676AbZELJ2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 05:28:00 -0400
Content-Disposition: inline; filename=02-driver-maintainers.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 CREDITS     |    4 ++++
 MAINTAINERS |    7 +++++++
 2 files changed, 11 insertions(+)

Index: net-next-2.6/CREDITS
===================================================================
--- net-next-2.6.orig/CREDITS	2009-05-12 10:47:10.501721461 +0200
+++ net-next-2.6/CREDITS	2009-05-12 10:47:24.371720546 +0200
@@ -1253,6 +1253,10 @@
 S: Sterling Heights, Michigan 48313
 S: USA
 
+N: Wolfgang Grandegger
+E: wg@grandegger.com
+D: Controller Area Network (device drivers)
+
 N: William Greathouse
 E: wgreathouse@smva.com
 E: wgreathouse@myfavoritei.com
Index: net-next-2.6/MAINTAINERS
===================================================================
--- net-next-2.6.orig/MAINTAINERS	2009-05-12 10:47:10.501721461 +0200
+++ net-next-2.6/MAINTAINERS	2009-05-12 10:47:24.374720415 +0200
@@ -1278,6 +1278,13 @@
 F:	include/linux/can/
 F:	include/linux/can.h
 
+CAN NETWORK DRIVERS
+P:	Wolfgang Grandegger
+M:	wg@grandegger.com
+L:	socketcan-core@lists.berlios.de (subscribers-only)
+W:	http://developer.berlios.de/projects/socketcan/
+S:	Maintained
+
 CELL BROADBAND ENGINE ARCHITECTURE
 P:	Arnd Bergmann
 M:	arnd@arndb.de

