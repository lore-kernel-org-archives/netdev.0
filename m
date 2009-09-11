From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 5/5] netxen: update copyright
Date: Fri, 11 Sep 2009 14:28:15 -0700
Message-ID: <1252704495-16118-6-git-send-email-dhananjay@netxen.com>
References: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43928 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756916AbZIKV2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:28:14 -0400
In-Reply-To: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Add QLogic copyright, add linux-driver@qlogic.com to
  MAINTAINERS.
o Delete old contact information.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/Makefile             |    7 +------
 drivers/net/netxen/netxen_nic.h         |    7 +------
 drivers/net/netxen/netxen_nic_ctx.c     |    7 +------
 drivers/net/netxen/netxen_nic_ethtool.c |    7 +------
 drivers/net/netxen/netxen_nic_hdr.h     |    7 +------
 drivers/net/netxen/netxen_nic_hw.c      |    7 +------
 drivers/net/netxen/netxen_nic_hw.h      |    7 +------
 drivers/net/netxen/netxen_nic_init.c    |    7 +------
 drivers/net/netxen/netxen_nic_main.c    |    7 +------
 9 files changed, 9 insertions(+), 54 deletions(-)

diff --git a/drivers/net/netxen/Makefile b/drivers/net/netxen/Makefile
index a70b682..11d94e2 100644
--- a/drivers/net/netxen/Makefile
+++ b/drivers/net/netxen/Makefile
@@ -1,4 +1,5 @@
 # Copyright (C) 2003 - 2009 NetXen, Inc.
+# Copyright (C) 2009 - QLogic Corporation.
 # All rights reserved.
 # 
 # This program is free software; you can redistribute it and/or
@@ -19,12 +20,6 @@
 # The full GNU General Public License is included in this distribution
 # in the file called LICENSE.
 # 
-# Contact Information:
-#    info@netxen.com
-# NetXen Inc,
-# 18922 Forge Drive
-# Cupertino, CA 95014-0701
-#
 #
 
 
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 1ae46e8..7384f59 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2003 - 2009 NetXen, Inc.
+ * Copyright (C) 2009 - QLogic Corporation.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -20,12 +21,6 @@
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
  *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
  */
 
 #ifndef _NETXEN_NIC_H_
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 33f82db..9cb8f68 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2003 - 2009 NetXen, Inc.
+ * Copyright (C) 2009 - QLogic Corporation.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -20,12 +21,6 @@
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
  *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
  */
 
 #include "netxen_nic_hw.h"
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index d18832c..714f387 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2003 - 2009 NetXen, Inc.
+ * Copyright (C) 2009 - QLogic Corporation.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -20,12 +21,6 @@
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
  *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
  */
 
 #include <linux/types.h>
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 26188b4..7a71774 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2003 - 2009 NetXen, Inc.
+ * Copyright (C) 2009 - QLogic Corporation.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -20,12 +21,6 @@
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
  *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
  */
 
 #ifndef __NETXEN_NIC_HDR_H_
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 018cf42..3231400 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2003 - 2009 NetXen, Inc.
+ * Copyright (C) 2009 - QLogic Corporation.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -20,12 +21,6 @@
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
  *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
  */
 
 #include "netxen_nic.h"
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 98e4b95..3fd1dcb 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2003 - 2009 NetXen, Inc.
+ * Copyright (C) 2009 - QLogic Corporation.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -20,12 +21,6 @@
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
  *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
  */
 
 #ifndef __NETXEN_NIC_HW_H_
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 128d1b6..91c2bc6 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2003 - 2009 NetXen, Inc.
+ * Copyright (C) 2009 - QLogic Corporation.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -20,12 +21,6 @@
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
  *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
  */
 
 #include <linux/netdevice.h>
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2b1b939..c4f2427 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2003 - 2009 NetXen, Inc.
+ * Copyright (C) 2009 - QLogic Corporation.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -20,12 +21,6 @@
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
  *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
  */
 
 #include <linux/vmalloc.h>
-- 
1.6.0.2

