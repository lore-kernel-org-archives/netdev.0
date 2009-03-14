From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 10/10] Neterion: New driver: Driver Version
Date: 14 Mar 2009 00:22:07 -0800
Message-ID: <1237018922.4966.439.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:60415 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbZCNHxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 03:53:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Driver version details.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN patch_9/drivers/net/vxge/vxge-version.h patch_10/drivers/net/vxge/vxge-version.h
--- patch_9/drivers/net/vxge/vxge-version.h	1969-12-31 16:00:00.000000000 -0800
+++ patch_10/drivers/net/vxge/vxge-version.h	2009-03-13 01:47:58.000000000 -0700
@@ -0,0 +1,24 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ ******************************************************************************/
+/*******************************************************************************
+ * vxge-version.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ *                 Virtualized Server Adapter.
+ * Copyright(c) 2002-2009 Neterion Inc.
+ ******************************************************************************/
+#ifndef VXGE_VERSION_H
+
+#define VXGE_VERSION_H
+
+#define VXGE_VERSION_MAJOR	"2"
+#define VXGE_VERSION_MINOR	"0"
+#define VXGE_VERSION_FIX	"1"
+#define VXGE_VERSION_BUILD	"16730"
+#define VXGE_VERSION_FOR	"vxge"
+#endif



