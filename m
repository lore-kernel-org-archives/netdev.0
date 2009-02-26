From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next] netxen: update copyright
Date: Wed, 25 Feb 2009 17:57:56 -0800
Message-ID: <1235613476-28334-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33800 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751435AbZBZB6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 20:58:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend copyright into 2009 and update address.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/Makefile              |    9 ++++-----
 drivers/net/netxen/netxen_nic.h          |    9 +++++----
 drivers/net/netxen/netxen_nic_ctx.c      |    8 ++++----
 drivers/net/netxen/netxen_nic_ethtool.c  |   11 ++++-------
 drivers/net/netxen/netxen_nic_hdr.h      |    9 +++++----
 drivers/net/netxen/netxen_nic_hw.c       |   11 ++++-------
 drivers/net/netxen/netxen_nic_hw.h       |   11 ++++-------
 drivers/net/netxen/netxen_nic_init.c     |   11 ++++-------
 drivers/net/netxen/netxen_nic_main.c     |   11 ++++-------
 drivers/net/netxen/netxen_nic_niu.c      |   11 ++++-------
 drivers/net/netxen/netxen_nic_phan_reg.h |    9 +++++----
 11 files changed, 47 insertions(+), 63 deletions(-)

diff --git a/drivers/net/netxen/Makefile b/drivers/net/netxen/Makefile
index 8e7c4c9..cf01a91 100644
--- a/drivers/net/netxen/Makefile
+++ b/drivers/net/netxen/Makefile
@@ -1,4 +1,4 @@
-# Copyright (C) 2003 - 2006 NetXen, Inc.
+# Copyright (C) 2003 - 2009 NetXen, Inc.
 # All rights reserved.
 # 
 # This program is free software; you can redistribute it and/or
@@ -21,11 +21,10 @@
 # 
 # Contact Information:
 #    info@netxen.com
-# NetXen,
-# 3965 Freedom Circle, Fourth floor,
-# Santa Clara, CA 95054
+# NetXen Inc,
+# 18922 Forge Drive
+# Cupertino, CA 95014-0701
 #
-# Makefile for the NetXen NIC Driver
 #
 
 
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index b726182..bbdd8f2 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,9 +22,10 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
+ *
  */
 
 #ifndef _NETXEN_NIC_H_
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 746bdb4..3e43706 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2008 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,9 +22,9 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 87803f1..6b25121 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,12 +22,9 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
- *
- *
- * ethtool support for netxen nic
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 4695246..e589d4b 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,9 +22,10 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
+ *
  */
 
 #ifndef __NETXEN_NIC_HDR_H_
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index b6b777e..b15246c 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,12 +22,9 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
- *
- *
- * Source file for NIC routines to access the Phantom hardware
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 9dcfb32..9fb5162 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,12 +22,9 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
- *
- *
- * Structures, enums, and macros for the MAC
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 688f880..f323cee 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,12 +22,9 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
- *
- *
- * Source file for NIC routines to initialize the Phantom Hardware
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index c2b551f..02f5240 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,12 +22,9 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
- *
- *
- *  Main source file for NetXen NIC Driver on Linux
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 3851a67..d852032 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,12 +22,9 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
- *
- *
- * Provides access to the Network Interface Unit h/w block.
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index b293adc..2a368f2 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * Copyright (C) 2003 - 2009 NetXen, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
@@ -22,9 +22,10 @@
  *
  * Contact Information:
  *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
+ * NetXen Inc,
+ * 18922 Forge Drive
+ * Cupertino, CA 95014-0701
+ *
  */
 
 #ifndef __NIC_PHAN_REG_H_
-- 
1.6.0.2

