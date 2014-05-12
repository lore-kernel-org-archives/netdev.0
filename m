From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 3/3] tg3: Update copyright and version to 3.137
Date: Sun, 11 May 2014 20:22:55 -0700
Message-ID: <1399864975-29070-4-git-send-email-mchan@broadcom.com>
References: <1399864975-29070-1-git-send-email-mchan@broadcom.com>
 <1399864975-29070-2-git-send-email-mchan@broadcom.com>
 <1399864975-29070-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <prashant@broadcom.com>,
	<ivecera@redhat.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:50292 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932484AbaELCCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 22:02:18 -0400
In-Reply-To: <1399864975-29070-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 +++---
 drivers/net/ethernet/broadcom/tg3.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 36b2b51..ccd9015 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4,7 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001, 2002, 2003 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
- * Copyright (C) 2005-2013 Broadcom Corporation.
+ * Copyright (C) 2005-2014 Broadcom Corporation.
  *
  * Firmware is:
  *	Derived from proprietary unpublished source code,
@@ -94,10 +94,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			136
+#define TG3_MIN_NUM			137
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"Jan 03, 2014"
+#define DRV_MODULE_RELDATE	"May 11, 2014"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 04321e5..461acca 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
- * Copyright (C) 2007-2013 Broadcom Corporation.
+ * Copyright (C) 2007-2014 Broadcom Corporation.
  */
 
 #ifndef _T3_H
-- 
1.7.1
