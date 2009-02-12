From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 41/41]bnx2x: Version
Date: Thu, 12 Feb 2009 20:38:35 +0200
Message-ID: <1234463915.1863.173.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3835 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759163AbZBLSjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:39:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 41/41]bnx2x: Version
And updating the year

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_fw_defs.h |    2 +-
 drivers/net/bnx2x_hsi.h     |    2 +-
 drivers/net/bnx2x_init.h    |    2 +-
 drivers/net/bnx2x_link.h    |    2 +-
 drivers/net/bnx2x_main.c    |    4 ++--
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 05d695d..e2df238 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_defs.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2008 Broadcom Corporation
+ * Copyright (c) 2007-2009 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index c1ba05c..03c6242 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1,6 +1,6 @@
 /* bnx2x_hsi.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2008 Broadcom Corporation
+ * Copyright (c) 2007-2009 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index ba370f7..8af2757 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -1,6 +1,6 @@
 /* bnx2x_init.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2008 Broadcom Corporation
+ * Copyright (c) 2007-2009 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index 027116a..19a866d 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -1,4 +1,4 @@
-/* Copyright 2008 Broadcom Corporation
+/* Copyright 2008-2009 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 4b0476c..9427175 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -54,8 +54,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION	"1.45.26"
-#define DRV_MODULE_RELDATE	"2009/01/26"
+#define DRV_MODULE_VERSION	"1.48.102"
+#define DRV_MODULE_RELDATE	"2009/02/12"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung */
-- 
1.5.4.3




