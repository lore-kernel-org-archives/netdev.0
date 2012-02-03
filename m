From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/7] ixgbevf: Update copyright notices
Date: Fri,  3 Feb 2012 03:15:01 -0800
Message-ID: <1328267703-9638-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53720 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755976Ab2BCLPT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 06:15:19 -0500
In-Reply-To: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Robert E Garrett <robertX.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/Makefile       |    2 +-
 drivers/net/ethernet/intel/ixgbevf/defines.h      |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    4 ++--
 drivers/net/ethernet/intel/ixgbevf/mbx.c          |    2 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |    2 +-
 drivers/net/ethernet/intel/ixgbevf/regs.h         |    2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |    2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +-
 10 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/Makefile b/drivers/net/ethernet/intel/ixgbevf/Makefile
index 1f35d22..4ce4c97 100644
--- a/drivers/net/ethernet/intel/ixgbevf/Makefile
+++ b/drivers/net/ethernet/intel/ixgbevf/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel 82599 Virtual Function driver
-# Copyright(c) 1999 - 2010 Intel Corporation.
+# Copyright(c) 1999 - 2012 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 2eb89cb..947b5c8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index c857003..2bfe0d1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 9075c1d..dfed420 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 3044a56..e51d552 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -60,7 +60,7 @@ static const char ixgbevf_driver_string[] =
 #define DRV_VERSION "2.2.0-k"
 const char ixgbevf_driver_version[] = DRV_VERSION;
 static char ixgbevf_copyright[] =
-	"Copyright (c) 2009 - 2010 Intel Corporation.";
+	"Copyright (c) 2009 - 2012 Intel Corporation.";
 
 static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
 	[board_82599_vf] = &ixgbevf_82599_vf_info,
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.c b/drivers/net/ethernet/intel/ixgbevf/mbx.c
index 13532d9..9c95590 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.c
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 9d38a94..cf9131c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbevf/regs.h b/drivers/net/ethernet/intel/ixgbevf/regs.h
index 5e4d5e5..debd8c0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/regs.h
+++ b/drivers/net/ethernet/intel/ixgbevf/regs.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 77a19d9..74be741 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index d556619..25c951d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
-- 
1.7.7.6
