From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 34/34]bnx2x: Version update
Date: Wed, 14 Jan 2009 18:44:31 +0200
Message-ID: <1231951471.11301.155.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2905 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764244AbZANQpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:45:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updating the version and the year of updated files

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 +-
 drivers/net/bnx2x_link.c |    2 +-
 drivers/net/bnx2x_main.c |    6 +++---
 drivers/net/bnx2x_reg.h  |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 0e848fe..1aa8d83 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1,6 +1,6 @@
 /* bnx2x.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2008 Broadcom Corporation
+ * Copyright (c) 2007-2009 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index b4527a4..aea26b4 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1,4 +1,4 @@
-/* Copyright 2008 Broadcom Corporation
+/* Copyright 2008-2009 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2aa2943..a0296c0 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1,6 +1,6 @@
 /* bnx2x_main.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2008 Broadcom Corporation
+ * Copyright (c) 2007-2009 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -57,8 +57,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION	"1.45.23"
-#define DRV_MODULE_RELDATE	"2008/11/03"
+#define DRV_MODULE_VERSION	"1.45.24"
+#define DRV_MODULE_RELDATE	"2009/01/14"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung */
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index ed0d19a..650cc07 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1,6 +1,6 @@
 /* bnx2x_reg.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2008 Broadcom Corporation
+ * Copyright (c) 2007-2009 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.5.4.3




