From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 11/11] tg3: Update copyrights and update
 version to 3.117
Date: Tue, 25 Jan 2011 17:58:57 -0800
Message-ID: <1296007137-23146-12-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3912 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752506Ab1AZB7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates copyrights and updates the tg3 version to 3.117.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 +++---
 drivers/net/tg3.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c7ac812..4ca0b7a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4,7 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001, 2002, 2003 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
- * Copyright (C) 2005-2010 Broadcom Corporation.
+ * Copyright (C) 2005-2011 Broadcom Corporation.
  *
  * Firmware is:
  *	Derived from proprietary unpublished source code,
@@ -64,10 +64,10 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			116
+#define TG3_MIN_NUM			117
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"December 3, 2010"
+#define DRV_MODULE_RELDATE	"January 25, 2011"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 716fc00..73884b6 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
- * Copyright (C) 2007-2010 Broadcom Corporation.
+ * Copyright (C) 2007-2011 Broadcom Corporation.
  */
 
 #ifndef _T3_H
-- 
1.7.2.2


