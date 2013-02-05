From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] ixgbe: update date to 2013
Date: Tue,  5 Feb 2013 02:02:26 -0800
Message-ID: <1360058548-18158-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50769 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753698Ab3BEKC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 05:02:59 -0500
In-Reply-To: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/Makefile          | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h       | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c   | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h      | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      | 2 +-
 29 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/Makefile b/drivers/net/ethernet/intel/ixgbe/Makefile
index 687c83d..be2989e 100644
--- a/drivers/net/ethernet/intel/ixgbe/Makefile
+++ b/drivers/net/ethernet/intel/ixgbe/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel 10 Gigabit PCI Express Linux driver
-# Copyright(c) 1999 - 2012 Intel Corporation.
+# Copyright(c) 1999 - 2013 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8371ae4..2a61889 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 6030de5..d0113fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index d1f4d45..203a00c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 5e68afd..99e472e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index f7a0970..bc3948ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index 9bc17c0..1f2c805 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
index 1f4108e..1634de8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
index 87592b4..ac78077 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h
index ba83570..3164f54 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
index 4eac80d..05e23b8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
index 4dec47f..a4ef076 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 3735590..f3d68f9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
index 3504686..c5933f6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 355ca08..db67359 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 4968367..c116884 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h
index bf724da..3a02759 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 8c74f73..9ffa330 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ac41361..88500dd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -66,7 +66,7 @@ static char ixgbe_default_device_descr[] =
 #define DRV_VERSION "3.11.33-k"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
-				"Copyright (c) 1999-2012 Intel Corporation.";
+				"Copyright (c) 1999-2013 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598] = &ixgbe_82598_info,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
index 1f3e32b..d4a64e6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index 42dd65e..e44ff47 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index d034cc5..eb534a0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index bbfe55c..886a343 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 53d2047..331987d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index ee3507f..d44b4d2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 008f9ce..4713f9f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index 16ddf14..d118def 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 1af6289..6652e96 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 4dc3725..66c5e94 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
-- 
1.7.11.7
