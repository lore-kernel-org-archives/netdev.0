From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 13/14] tg3: Update copyright and version
Date: Wed, 25 Feb 2009 16:40:42 -0800
Message-ID: <1235616380.16031@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3031 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753709AbZBZCq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the copyright to 2009 and updates the version number
to 3.98.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d12338f..f7efcec 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4,7 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001, 2002, 2003 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
- * Copyright (C) 2005-2007 Broadcom Corporation.
+ * Copyright (C) 2005-2009 Broadcom Corporation.
  *
  * Firmware is:
  *	Derived from proprietary unpublished source code,
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.97"
-#define DRV_MODULE_RELDATE	"December 10, 2008"
+#define DRV_MODULE_VERSION	"3.98"
+#define DRV_MODULE_RELDATE	"February 25, 2009"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.6.0.6


