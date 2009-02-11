From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/4] bnx2: Update version to 1.9.2 and copyright.
Date: Wed, 11 Feb 2009 15:52:18 -0800
Message-ID: <1234396338-14859-4-git-send-email-mchan@broadcom.com>
References: <1234396338-14859-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1109 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753036AbZBKXoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 18:44:25 -0500
In-Reply-To: <1234396338-14859-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++---
 drivers/net/bnx2.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 903d13b..8466d35 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1,6 +1,6 @@
 /* bnx2.c: Broadcom NX2 network driver.
  *
- * Copyright (c) 2004-2008 Broadcom Corporation
+ * Copyright (c) 2004-2009 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.9.0"
-#define DRV_MODULE_RELDATE	"Dec 16, 2008"
+#define DRV_MODULE_VERSION	"1.9.2"
+#define DRV_MODULE_RELDATE	"Feb 11, 2009"
 
 #define RUN_AT(x) (jiffies + (x))
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 900641a..704cbbc 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -1,6 +1,6 @@
 /* bnx2.h: Broadcom NX2 network driver.
  *
- * Copyright (c) 2004-2007 Broadcom Corporation
+ * Copyright (c) 2004-2009 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.5.6.GIT


