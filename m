From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/6 net-next] bnx2: Update version to 2.2.4
Date: Tue, 6 Aug 2013 15:50:12 -0700
Message-ID: <1375829412-26425-7-git-send-email-mchan@broadcom.com>
References: <1375829412-26425-1-git-send-email-mchan@broadcom.com>
 <1375829412-26425-2-git-send-email-mchan@broadcom.com>
 <1375829412-26425-3-git-send-email-mchan@broadcom.com>
 <1375829412-26425-4-git-send-email-mchan@broadcom.com>
 <1375829412-26425-5-git-send-email-mchan@broadcom.com>
 <1375829412-26425-6-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4003 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756655Ab3HFW2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 18:28:09 -0400
In-Reply-To: <1375829412-26425-6-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

and update copyright year.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    6 +++---
 drivers/net/ethernet/broadcom/bnx2.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 88f5ab1..6fdfc18 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -1,6 +1,6 @@
 /* bnx2.c: Broadcom NX2 network driver.
  *
- * Copyright (c) 2004-2011 Broadcom Corporation
+ * Copyright (c) 2004-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -58,8 +58,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.2.3"
-#define DRV_MODULE_RELDATE	"June 27, 2012"
+#define DRV_MODULE_VERSION	"2.2.4"
+#define DRV_MODULE_RELDATE	"Aug 05, 2013"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.2.3.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.2.1b.fw"
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 172efbe..18cb2d2 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -1,6 +1,6 @@
 /* bnx2.h: Broadcom NX2 network driver.
  *
- * Copyright (c) 2004-2011 Broadcom Corporation
+ * Copyright (c) 2004-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.7.1
