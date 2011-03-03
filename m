From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 24/24] ixgbe: cleanup copyright string for 2011
Date: Thu,  3 Mar 2011 05:03:49 -0800
Message-ID: <1299157429-15878-25-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22392 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758218Ab1CCNE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:27 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Updating the copyrights for 2011 as well as make the ixgbe_copyright string
a constant.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
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
 drivers/net/ixgbe/ixgbe_main.c      |    5 +++--
 drivers/net/ixgbe/ixgbe_mbx.c       |    2 +-
 drivers/net/ixgbe/ixgbe_mbx.h       |    2 +-
 drivers/net/ixgbe/ixgbe_phy.c       |    2 +-
 drivers/net/ixgbe/ixgbe_phy.h       |    2 +-
 drivers/net/ixgbe/ixgbe_sriov.c     |    2 +-
 drivers/net/ixgbe/ixgbe_sriov.h     |    2 +-
 drivers/net/ixgbe/ixgbe_type.h      |    2 +-
 drivers/net/ixgbe/ixgbe_x540.c      |    2 +-
 24 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 12769b5..b60b81b 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 2da629a..fc41329 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 8f7c6bd..5ef968a 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index bd14ea4..a7fb2e0 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 90ac609..508f635 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index 13c962e..c2ee6fc 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index e593511..515bc27 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index 2965edc..c97cf91 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ixgbe/ixgbe_dcb_82598.h
index 0d2a758..1e9750c 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index b0d97a9..beaa1c1 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ixgbe/ixgbe_dcb_82599.h
index 5b0ca85..0b39ab4 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index a977df3..d7f0024 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 309272f..83511c0 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index c54a882..27203c8 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index 65cc8fb..02a00d2 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9877719..32231ff 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -54,7 +54,8 @@ static const char ixgbe_driver_string[] =
 
 #define DRV_VERSION "3.2.9-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
-static char ixgbe_copyright[] = "Copyright (c) 1999-2010 Intel Corporation.";
+static const char ixgbe_copyright[] =
+				"Copyright (c) 1999-2011 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598] = &ixgbe_82598_info,
diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
index f215c4c..2acacfa 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_mbx.h b/drivers/net/ixgbe/ixgbe_mbx.h
index ada0ce3..fe6ea81 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ixgbe/ixgbe_mbx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index f4569e8..197230b 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index e2c6b7e..2327baf 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index fb4868d..58c9b45 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_sriov.h b/drivers/net/ixgbe/ixgbe_sriov.h
index 49dc14d..e7dd029 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ixgbe/ixgbe_sriov.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index e940f23..013751d 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index eb04773..2e3a2b4 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
-- 
1.7.4

