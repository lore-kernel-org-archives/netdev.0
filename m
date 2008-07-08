From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 25/25] ixgb: update copyright dates and versions
Date: Tue, 08 Jul 2008 15:53:09 -0700
Message-ID: <20080708225309.6925.91758.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58387 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755025AbYGHWxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:53:10 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/Makefile       |    2 +-
 drivers/net/ixgb/ixgb.h         |    2 +-
 drivers/net/ixgb/ixgb_ee.c      |    2 +-
 drivers/net/ixgb/ixgb_ee.h      |    2 +-
 drivers/net/ixgb/ixgb_ethtool.c |    2 +-
 drivers/net/ixgb/ixgb_hw.c      |    2 +-
 drivers/net/ixgb/ixgb_hw.h      |    2 +-
 drivers/net/ixgb/ixgb_ids.h     |    2 +-
 drivers/net/ixgb/ixgb_main.c    |    6 +++---
 drivers/net/ixgb/ixgb_osdep.h   |    2 +-
 drivers/net/ixgb/ixgb_param.c   |    2 +-
 11 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgb/Makefile b/drivers/net/ixgb/Makefile
index 838a508..0b20c5e 100644
--- a/drivers/net/ixgb/Makefile
+++ b/drivers/net/ixgb/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel PRO/10GbE Linux driver
-# Copyright(c) 1999 - 2006 Intel Corporation.
+# Copyright(c) 1999 - 2008 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 5e8a605..804698f 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 4a9e52f..89ffa72 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ixgb/ixgb_ee.h
index 12136b6..7ea1265 100644
--- a/drivers/net/ixgb/ixgb_ee.h
+++ b/drivers/net/ixgb/ixgb_ee.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index e1836c1..288ee1d 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 9cc75ce..11dcda0 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index 39cfa47..831fe0c 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
index 4ba4d19..2a58847 100644
--- a/drivers/net/ixgb/ixgb_ids.h
+++ b/drivers/net/ixgb/ixgb_ids.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 5264134..e83feaf 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -32,9 +32,9 @@ char ixgb_driver_name[] = "ixgb";
 static char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
 
 #define DRIVERNAPI "-NAPI"
-#define DRV_VERSION "1.0.126" DRIVERNAPI
+#define DRV_VERSION "1.0.135-k2" DRIVERNAPI
 const char ixgb_driver_version[] = DRV_VERSION;
-static const char ixgb_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
+static const char ixgb_copyright[] = "Copyright (c) 1999-2008 Intel Corporation.";
 
 #define IXGB_CB_LENGTH 256
 static unsigned int copybreak __read_mostly = IXGB_CB_LENGTH;
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
index fb74bb1..d92e72b 100644
--- a/drivers/net/ixgb/ixgb_osdep.h
+++ b/drivers/net/ixgb/ixgb_osdep.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 169636a..af35e1d 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,

