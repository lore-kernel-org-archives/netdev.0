From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.25 4/4][BNX2] Update version to 1.7.2.
Date: Mon, 21 Jan 2008 17:08:42 -0800
Message-ID: <1200964122.10010.49.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1162 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306AbYAVA1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 19:27:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2] Update version to 1.7.2.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 834675f..970a003 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1,6 +1,6 @@
 /* bnx2.c: Broadcom NX2 network driver.
  *
- * Copyright (c) 2004-2007 Broadcom Corporation
+ * Copyright (c) 2004-2008 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.1"
-#define DRV_MODULE_RELDATE	"December 19, 2007"
+#define DRV_MODULE_VERSION	"1.7.2"
+#define DRV_MODULE_RELDATE	"January 21, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 


