From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] ixgbe: Update copyright dates,
	bump the driver version number
Date: Fri, 30 Jan 2009 17:06:17 -0800
Message-ID: <20090131010616.1820.93633.stgit@lost.foo-projects.org>
References: <20090131010530.1820.5846.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:47431
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753293AbZAaBGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 20:06:37 -0500
In-Reply-To: <20090131010530.1820.5846.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

New year, new copyright date ranges.  Also bump the driver version
number to reflect many of the recent changes.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/Makefile          |    2 +-
 drivers/net/ixgbe/ixgbe.h           |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c     |    2 +-
 drivers/net/ixgbe/ixgbe_common.c    |    2 +-
 drivers/net/ixgbe/ixgbe_common.h    |    2 +-
 drivers/net/ixgbe/ixgbe_dcb.c       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb.h       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.h |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |    2 +-
 drivers/net/ixgbe/ixgbe_ethtool.c   |    2 +-
 drivers/net/ixgbe/ixgbe_main.c      |    6 +++---
 drivers/net/ixgbe/ixgbe_phy.c       |    2 +-
 drivers/net/ixgbe/ixgbe_phy.h       |    2 +-
 drivers/net/ixgbe/ixgbe_type.h      |    2 +-
 15 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
index 6e7ef76..f606195 100644
--- a/drivers/net/ixgbe/Makefile
+++ b/drivers/net/ixgbe/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel 10 Gigabit PCI Express Linux driver
-# Copyright(c) 1999 - 2007 Intel Corporation.
+# Copyright(c) 1999 - 2009 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 341d8b5..0ea791a 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 7fb4b86..8e7315e 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index f67c684..05f0e87 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 192f8d0..0b5ba57 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index e2e28ac..2a60c89 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index 75f6efe..0da5c6d 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index 2c046b0..5603211 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ixgbe/ixgbe_dcb_82598.h
index 1e6a313..ebbe53c 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 4129976..dd9d1d6 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 69eda89..14e661e 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7171399..ec98e26 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -47,9 +47,9 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
                               "Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "1.3.30-k2"
+#define DRV_VERSION "1.3.56-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
-static char ixgbe_copyright[] = "Copyright (c) 1999-2007 Intel Corporation.";
+static char ixgbe_copyright[] = "Copyright (c) 1999-2009 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598] = &ixgbe_82598_info,
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 5a8669a..77ec26f 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index 43a97bc..539a306 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 0d1d1d2..c49ba8a 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,

