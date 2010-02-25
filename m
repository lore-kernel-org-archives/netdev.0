From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 6/6] cnic: Update version to 2.1.1.
Date: Wed, 24 Feb 2010 16:42:09 -0800
Message-ID: <1267058529-18454-6-git-send-email-mchan@broadcom.com>
References: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
 <1267058529-18454-2-git-send-email-mchan@broadcom.com>
 <1267058529-18454-3-git-send-email-mchan@broadcom.com>
 <1267058529-18454-4-git-send-email-mchan@broadcom.com>
 <1267058529-18454-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2833 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758668Ab0BYAcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 19:32:43 -0500
In-Reply-To: <1267058529-18454-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And update copyright to 2010.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c      |    2 +-
 drivers/net/cnic.h      |    2 +-
 drivers/net/cnic_defs.h |    2 +-
 drivers/net/cnic_if.h   |    6 +++---
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 463408f..9781942 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1,6 +1,6 @@
 /* cnic.c: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2009 Broadcom Corporation
+ * Copyright (c) 2006-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index d566390..a0d853d 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -1,6 +1,6 @@
 /* cnic.h: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2009 Broadcom Corporation
+ * Copyright (c) 2006-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/cnic_defs.h b/drivers/net/cnic_defs.h
index 9827b27..7ce694d 100644
--- a/drivers/net/cnic_defs.h
+++ b/drivers/net/cnic_defs.h
@@ -1,7 +1,7 @@
 
 /* cnic.c: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2009 Broadcom Corporation
+ * Copyright (c) 2006-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 8aaf98b..110c620 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -1,6 +1,6 @@
 /* cnic_if.h: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006 Broadcom Corporation
+ * Copyright (c) 2006-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.1.0"
-#define CNIC_MODULE_RELDATE	"Oct 10, 2009"
+#define CNIC_MODULE_VERSION	"2.1.1"
+#define CNIC_MODULE_RELDATE	"Feb 22, 2010"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.6.4.GIT


