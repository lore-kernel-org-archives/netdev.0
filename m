From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: update copyright dates
Date: Wed, 13 Jan 2010 03:49:34 -0800
Message-ID: <20100113114933.23119.70815.stgit@localhost.localdomain>
References: <20100113114847.23119.36954.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:50030 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751224Ab0AMLtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 06:49:51 -0500
In-Reply-To: <20100113114847.23119.36954.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/Makefile          |    2 +-
 drivers/net/ixgbe/ixgbe.h           |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c     |    2 +-
 drivers/net/ixgbe/ixgbe_82599.c     |    2 +-
 drivers/net/ixgbe/ixgbe_common.c    |    2 +-
 drivers/net/ixgbe/ixgbe_common.h    |    2 +-
 drivers/net/ixgbe/ixgbe_dcb.c       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb.h       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.h |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.h |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |    2 +-
 drivers/net/ixgbe/ixgbe_ethtool.c   |    2 +-
 drivers/net/ixgbe/ixgbe_fcoe.c      |    2 +-
 drivers/net/ixgbe/ixgbe_fcoe.h      |    2 +-
 drivers/net/ixgbe/ixgbe_main.c      |    4 ++--
 drivers/net/ixgbe/ixgbe_phy.c       |    2 +-
 drivers/net/ixgbe/ixgbe_phy.h       |    2 +-
 drivers/net/ixgbe/ixgbe_type.h      |    2 +-
 20 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
index 21b41f4..bfef0eb 100644
--- a/drivers/net/ixgbe/Makefile
+++ b/drivers/net/ixgbe/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel 10 Gigabit PCI Express Linux driver
-# Copyright(c) 1999 - 2009 Intel Corporation.
+# Copyright(c) 1999 - 2010 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 8da8eb5..303e7bd 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 204177d..3103f41 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5383405..b49bd6b 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 688b8ca..21f158f 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 27f3214..dfff0ff 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index a156228..9aea4f0 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index 64a9fa1..5caafd4 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index f302638..f0e9279 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ixgbe/ixgbe_dcb_82598.h
index ebbe53c..cc728fa 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index ec8a252..4f7a26a 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ixgbe/ixgbe_dcb_82599.h
index 9e5e282..0f3f791 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 3c7a79a..56f37f6 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 0bd49d3..d77961f 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index da32a10..e9a20c8 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index de8ff53..abf4b2b 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3859767..9c9202f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -52,7 +52,7 @@ static const char ixgbe_driver_string[] =
 
 #define DRV_VERSION "2.0.44-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
-static char ixgbe_copyright[] = "Copyright (c) 1999-2009 Intel Corporation.";
+static char ixgbe_copyright[] = "Copyright (c) 1999-2010 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598] = &ixgbe_82598_info,
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 9ecad17..1c1efd3 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index 9b700f5..9cf5f3b 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 84650c6..9eafddf 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,

