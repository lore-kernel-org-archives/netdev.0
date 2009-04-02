From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 8/9] Neterion: New driver: Driver version
Date: 01 Apr 2009 20:15:22 -0800
Message-ID: <1238645718.18544.234.camel@flash>
References: <1238194489.5516.391.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33615 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757084AbZDBDcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 23:32:47 -0400
In-Reply-To: <1238194489.5516.391.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Driver version

- Changes from previous submission -
 - Updated driver version.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_7/drivers/net/vxge/vxge-version.h patch_8/drivers/net/vxge/vxge-version.h
--- patch_7/drivers/net/vxge/vxge-version.h	1969-12-31 16:00:00.000000000 -0800
+++ patch_8/drivers/net/vxge/vxge-version.h	2009-04-01 12:19:48.000000000 -0700
@@ -0,0 +1,23 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ *
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
+#define VXGE_VERSION_BUILD	"17129"
+#define VXGE_VERSION_FOR	"k"
+#endif



