From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 20/20][BNX2]: Update version and reldate.
Date: Tue, 01 May 2007 18:18:05 -0700
Message-ID: <1178068685.4820.56.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2323 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992516AbXEBAbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 20:31:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Update version and reldate.

Update version to 1.5.10.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index fc25d2c..7da6340 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1,6 +1,6 @@
 /* bnx2.c: Broadcom NX2 network driver.
  *
- * Copyright (c) 2004, 2005, 2006 Broadcom Corporation
+ * Copyright (c) 2004-2007 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.8"
-#define DRV_MODULE_RELDATE	"April 24, 2007"
+#define DRV_MODULE_VERSION	"1.5.10"
+#define DRV_MODULE_RELDATE	"May 1, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 322153c..bd6288d 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -1,6 +1,6 @@
 /* bnx2.h: Broadcom NX2 network driver.
  *
- * Copyright (c) 2004, 2005, 2006 Broadcom Corporation
+ * Copyright (c) 2004-2007 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by


