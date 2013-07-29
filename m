From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/6 net-next] cnic: Update version to 2.5.17 and
 copyright year.
Date: Sun, 28 Jul 2013 19:04:00 -0700
Message-ID: <1375063440-4016-6-git-send-email-mchan@broadcom.com>
References: <1375063440-4016-1-git-send-email-mchan@broadcom.com>
 <1375063440-4016-2-git-send-email-mchan@broadcom.com>
 <1375063440-4016-3-git-send-email-mchan@broadcom.com>
 <1375063440-4016-4-git-send-email-mchan@broadcom.com>
 <1375063440-4016-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2889 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642Ab3G2BmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 21:42:10 -0400
In-Reply-To: <1375063440-4016-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c      |    2 +-
 drivers/net/ethernet/broadcom/cnic.h      |    2 +-
 drivers/net/ethernet/broadcom/cnic_defs.h |    2 +-
 drivers/net/ethernet/broadcom/cnic_if.h   |    6 +++---
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 07ec4ce..6bd6d14 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1,6 +1,6 @@
 /* cnic.c: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2012 Broadcom Corporation
+ * Copyright (c) 2006-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 62c6706..e7a2474 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -1,6 +1,6 @@
 /* cnic.h: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2011 Broadcom Corporation
+ * Copyright (c) 2006-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/cnic_defs.h b/drivers/net/ethernet/broadcom/cnic_defs.h
index e53f09d..95a8e4b 100644
--- a/drivers/net/ethernet/broadcom/cnic_defs.h
+++ b/drivers/net/ethernet/broadcom/cnic_defs.h
@@ -1,7 +1,7 @@
 
 /* cnic.c: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2012 Broadcom Corporation
+ * Copyright (c) 2006-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index ec9bb9a..82a0312 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -1,6 +1,6 @@
 /* cnic_if.h: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2012 Broadcom Corporation
+ * Copyright (c) 2006-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -14,8 +14,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.16"
-#define CNIC_MODULE_RELDATE	"Dec 05, 2012"
+#define CNIC_MODULE_VERSION	"2.5.17"
+#define CNIC_MODULE_RELDATE	"July 28, 2013"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.7.1
