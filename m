From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 25/26] igb: update version number and copyright dates
Date: Sat, 07 Feb 2009 01:23:12 -0800
Message-ID: <20090207092312.15697.90244.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:35215 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752328AbZBGJXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:23:32 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Update the version number to 1.3.16 and update copyright dates for 2009.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/Makefile        |    2 +-
 drivers/net/igb/e1000_82575.c   |    2 +-
 drivers/net/igb/e1000_82575.h   |    2 +-
 drivers/net/igb/e1000_defines.h |    2 +-
 drivers/net/igb/e1000_hw.h      |    2 +-
 drivers/net/igb/e1000_mac.c     |    2 +-
 drivers/net/igb/e1000_mac.h     |    2 +-
 drivers/net/igb/e1000_nvm.c     |    2 +-
 drivers/net/igb/e1000_phy.c     |    2 +-
 drivers/net/igb/e1000_phy.h     |    2 +-
 drivers/net/igb/e1000_regs.h    |    2 +-
 drivers/net/igb/igb.h           |    2 +-
 drivers/net/igb/igb_ethtool.c   |    2 +-
 drivers/net/igb/igb_main.c      |    6 +++---
 14 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/igb/Makefile b/drivers/net/igb/Makefile
index 1927b3f..cda3ad5 100644
--- a/drivers/net/igb/Makefile
+++ b/drivers/net/igb/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel 82575 PCI-Express Ethernet Linux driver
-# Copyright(c) 1999 - 2007 Intel Corporation.
+# Copyright(c) 1999 - 2009 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 68a9822..7f43e25 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 - 2008 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index e0a376f..dd50237 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 - 2008 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index bff62dd..5342e23 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 - 2008 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 6d1564f..bd86ceb 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index e5d23e0..5c249e2 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index 4ef40d5..91461de 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index 3379864..a88bfe2 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index d73ea71..ff0050e 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_phy.h b/drivers/net/igb/e1000_phy.h
index 7499e5d..3228a86 100644
--- a/drivers/net/igb/e1000_phy.h
+++ b/drivers/net/igb/e1000_phy.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index bdf5d83..5038b73 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 0519ae4..e507449 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index de09430..bd050b1 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 6713840..8bc1ffa 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007-2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -48,12 +48,12 @@
 #endif
 #include "igb.h"
 
-#define DRV_VERSION "1.2.45-k2"
+#define DRV_VERSION "1.3.16-k2"
 char igb_driver_name[] = "igb";
 char igb_driver_version[] = DRV_VERSION;
 static const char igb_driver_string[] =
 				"Intel(R) Gigabit Ethernet Network Driver";
-static const char igb_copyright[] = "Copyright (c) 2008 Intel Corporation.";
+static const char igb_copyright[] = "Copyright (c) 2007-2009 Intel Corporation.";
 
 static const struct e1000_info *igb_info_tbl[] = {
 	[board_82575] = &e1000_82575_info,

