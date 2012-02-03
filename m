From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/7] igbvf: change copyright date
Date: Fri,  3 Feb 2012 03:15:02 -0800
Message-ID: <1328267703-9638-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1774 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755690Ab2BCLPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 06:15:20 -0500
In-Reply-To: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

Change copyright date to 2012 in the source files.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Robert E Garrett <robertX.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/Makefile  |    2 +-
 drivers/net/ethernet/intel/igbvf/defines.h |    2 +-
 drivers/net/ethernet/intel/igbvf/ethtool.c |    2 +-
 drivers/net/ethernet/intel/igbvf/igbvf.h   |    2 +-
 drivers/net/ethernet/intel/igbvf/mbx.c     |    2 +-
 drivers/net/ethernet/intel/igbvf/mbx.h     |    2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c  |    4 ++--
 drivers/net/ethernet/intel/igbvf/regs.h    |    2 +-
 drivers/net/ethernet/intel/igbvf/vf.c      |    2 +-
 drivers/net/ethernet/intel/igbvf/vf.h      |    2 +-
 10 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/Makefile b/drivers/net/ethernet/intel/igbvf/Makefile
index 0fa3db3..044b0ad 100644
--- a/drivers/net/ethernet/intel/igbvf/Makefile
+++ b/drivers/net/ethernet/intel/igbvf/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel(R) 82576 Virtual Function Linux driver
-# Copyright(c) 2009 - 2010 Intel Corporation.
+# Copyright(c) 2009 - 2012 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/igbvf/defines.h b/drivers/net/ethernet/intel/igbvf/defines.h
index 79f2604..33f40d3 100644
--- a/drivers/net/ethernet/intel/igbvf/defines.h
+++ b/drivers/net/ethernet/intel/igbvf/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 2dba534..db7dce2 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 - 2010 Intel Corporation.
+  Copyright(c) 2009 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/igbvf/igbvf.h b/drivers/net/ethernet/intel/igbvf/igbvf.h
index fd4a7b7..2c6d87e 100644
--- a/drivers/net/ethernet/intel/igbvf/igbvf.h
+++ b/drivers/net/ethernet/intel/igbvf/igbvf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 - 2010 Intel Corporation.
+  Copyright(c) 2009 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/igbvf/mbx.c b/drivers/net/ethernet/intel/igbvf/mbx.c
index 048aae2..b4b65bc 100644
--- a/drivers/net/ethernet/intel/igbvf/mbx.c
+++ b/drivers/net/ethernet/intel/igbvf/mbx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 - 2010 Intel Corporation.
+  Copyright(c) 2009 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/igbvf/mbx.h b/drivers/net/ethernet/intel/igbvf/mbx.h
index c2883c4..24370bc 100644
--- a/drivers/net/ethernet/intel/igbvf/mbx.h
+++ b/drivers/net/ethernet/intel/igbvf/mbx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index a4b20c8..4e9141c 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 - 2010 Intel Corporation.
+  Copyright(c) 2009 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -53,7 +53,7 @@ const char igbvf_driver_version[] = DRV_VERSION;
 static const char igbvf_driver_string[] =
 		  "Intel(R) Gigabit Virtual Function Network Driver";
 static const char igbvf_copyright[] =
-		  "Copyright (c) 2009 - 2011 Intel Corporation.";
+		  "Copyright (c) 2009 - 2012 Intel Corporation.";
 
 static int igbvf_poll(struct napi_struct *napi, int budget);
 static void igbvf_reset(struct igbvf_adapter *);
diff --git a/drivers/net/ethernet/intel/igbvf/regs.h b/drivers/net/ethernet/intel/igbvf/regs.h
index 77e18d3..7dc6341 100644
--- a/drivers/net/ethernet/intel/igbvf/regs.h
+++ b/drivers/net/ethernet/intel/igbvf/regs.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 - 2010 Intel Corporation.
+  Copyright(c) 2009 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index af3822f..1955197 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 - 2010 Intel Corporation.
+  Copyright(c) 2009 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/igbvf/vf.h b/drivers/net/ethernet/intel/igbvf/vf.h
index d7ed58f..57db3c6 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.h
+++ b/drivers/net/ethernet/intel/igbvf/vf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 - 2010 Intel Corporation.
+  Copyright(c) 2009 - 2012 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
-- 
1.7.7.6
