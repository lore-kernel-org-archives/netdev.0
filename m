From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/5] tg3: Update copyright and driver version
Date: Tue, 12 Jan 2010 12:11:40 -0800
Message-ID: <1263327100-13554-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1889 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754227Ab0ALUMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 15:12:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the copyright notice for 2010 and updates the version
number to 3.106.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 +++---
 drivers/net/tg3.h |    1 +
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2d1a740..7f82b02 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4,7 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001, 2002, 2003 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
- * Copyright (C) 2005-2009 Broadcom Corporation.
+ * Copyright (C) 2005-2010 Broadcom Corporation.
  *
  * Firmware is:
  *	Derived from proprietary unpublished source code,
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.105"
-#define DRV_MODULE_RELDATE	"December 2, 2009"
+#define DRV_MODULE_VERSION	"3.106"
+#define DRV_MODULE_RELDATE	"January 12, 2010"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 43ed41b..8a16791 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -4,6 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
+ * Copyright (C) 2007-2010 Broadcom Corporation.
  */
 
 #ifndef _T3_H
-- 
1.6.4.4


