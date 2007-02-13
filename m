From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 8/8]: Update copyright, version, and reldate.
Date: Tue, 13 Feb 2007 12:14:58 -0800
Message-ID: <1171397699.18944.32.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3531 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751814AbXBMTbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:31:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Update copyright, version, and reldate.

Update version to 3.73.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 159570b..81a1c2e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4,7 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001, 2002, 2003 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
- * Copyright (C) 2005 Broadcom Corporation.
+ * Copyright (C) 2005-2007 Broadcom Corporation.
  *
  * Firmware is:
  *	Derived from proprietary unpublished source code,
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.72"
-#define DRV_MODULE_RELDATE	"January 8, 2007"
+#define DRV_MODULE_VERSION	"3.73"
+#define DRV_MODULE_RELDATE	"February 12, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


