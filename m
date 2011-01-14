From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 2/3] e1000e: update Copyright for 2011
Date: Fri, 14 Jan 2011 03:42:29 -0800
Message-ID: <1295005350-28124-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1295005350-28124-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752393Ab1ANLme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 06:42:34 -0500
To: davem@davemloft.net
In-Reply-To: <1295005350-28124-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c   |    2 +-
 drivers/net/e1000e/Makefile  |    2 +-
 drivers/net/e1000e/defines.h |    2 +-
 drivers/net/e1000e/e1000.h   |    2 +-
 drivers/net/e1000e/es2lan.c  |    2 +-
 drivers/net/e1000e/ethtool.c |    2 +-
 drivers/net/e1000e/hw.h      |    2 +-
 drivers/net/e1000e/ich8lan.c |    2 +-
 drivers/net/e1000e/lib.c     |    2 +-
 drivers/net/e1000e/netdev.c  |    4 ++--
 drivers/net/e1000e/param.c   |    2 +-
 drivers/net/e1000e/phy.c     |    2 +-
 12 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index cb6c7b1..003a717 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/Makefile b/drivers/net/e1000e/Makefile
index 360c913..28519ac 100644
--- a/drivers/net/e1000e/Makefile
+++ b/drivers/net/e1000e/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel PRO/1000 Linux driver
-# Copyright(c) 1999 - 2008 Intel Corporation.
+# Copyright(c) 1999 - 2011 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 7245dc2..1314998 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 5255be7..e610e13 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index e45a61c..2fefa82 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index f8ed03d..fa08b63 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index e774380..efdbb28 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 5328a292..b43fc7f 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index ff28721..1c98dfa 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index fa5b604..04df745 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -6193,7 +6193,7 @@ static int __init e1000_init_module(void)
 	int ret;
 	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
 		e1000e_driver_version);
-	pr_info("Copyright (c) 1999 - 2010 Intel Corporation.\n");
+	pr_info("Copyright(c) 1999 - 2011 Intel Corporation.\n");
 	ret = pci_register_driver(&e1000_driver);
 
 	return ret;
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index a9612b0..d6f618d 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index a640f1c..eb6cbad 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
+  Copyright(c) 1999 - 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
-- 
1.7.3.4

