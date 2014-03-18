From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 3/3] cnic: Update version to 2.5.20 and copyright year.
Date: Mon, 17 Mar 2014 19:19:08 -0800
Message-ID: <1395112748-21965-4-git-send-email-mchan@broadcom.com>
References: <1395112748-21965-1-git-send-email-mchan@broadcom.com>
 <1395112748-21965-2-git-send-email-mchan@broadcom.com>
 <1395112748-21965-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eddie.wai@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:24933 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbaCRCAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 22:00:30 -0400
In-Reply-To: <1395112748-21965-3-git-send-email-mchan@broadcom.com>
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
index ea37ea2..09f3fef 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1,6 +1,6 @@
 /* cnic.c: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2013 Broadcom Corporation
+ * Copyright (c) 2006-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 0d6b13f..d535ae4 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -1,6 +1,6 @@
 /* cnic.h: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2013 Broadcom Corporation
+ * Copyright (c) 2006-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/cnic_defs.h b/drivers/net/ethernet/broadcom/cnic_defs.h
index 95a8e4b..dcbca69 100644
--- a/drivers/net/ethernet/broadcom/cnic_defs.h
+++ b/drivers/net/ethernet/broadcom/cnic_defs.h
@@ -1,7 +1,7 @@
 
 /* cnic.c: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2013 Broadcom Corporation
+ * Copyright (c) 2006-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 40bb563..5f4d557 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -1,6 +1,6 @@
 /* cnic_if.h: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2013 Broadcom Corporation
+ * Copyright (c) 2006-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -14,8 +14,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.19"
-#define CNIC_MODULE_RELDATE	"December 19, 2013"
+#define CNIC_MODULE_VERSION	"2.5.20"
+#define CNIC_MODULE_RELDATE	"March 14, 2014"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.7.1
