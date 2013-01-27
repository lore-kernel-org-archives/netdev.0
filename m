From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] e1000e: update copyright date
Date: Sun, 27 Jan 2013 02:39:46 -0800
Message-ID: <1359283193-2043-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35700 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756478Ab3A0KkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 05:40:03 -0500
In-Reply-To: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c | 2 +-
 drivers/net/ethernet/intel/e1000e/82571.c       | 2 +-
 drivers/net/ethernet/intel/e1000e/Makefile      | 2 +-
 drivers/net/ethernet/intel/e1000e/defines.h     | 2 +-
 drivers/net/ethernet/intel/e1000e/e1000.h       | 2 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c     | 2 +-
 drivers/net/ethernet/intel/e1000e/hw.h          | 2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c     | 2 +-
 drivers/net/ethernet/intel/e1000e/mac.c         | 2 +-
 drivers/net/ethernet/intel/e1000e/manage.c      | 2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      | 4 ++--
 drivers/net/ethernet/intel/e1000e/nvm.c         | 2 +-
 drivers/net/ethernet/intel/e1000e/param.c       | 2 +-
 drivers/net/ethernet/intel/e1000e/phy.c         | 2 +-
 drivers/net/ethernet/intel/e1000e/ptp.c         | 2 +-
 15 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index e73c2c3..97ff50e 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 587890d..e9d9bef 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/Makefile b/drivers/net/ethernet/intel/e1000e/Makefile
index 1da0faac..c2dcfcc 100644
--- a/drivers/net/ethernet/intel/e1000e/Makefile
+++ b/drivers/net/ethernet/intel/e1000e/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel PRO/1000 Linux driver
-# Copyright(c) 1999 - 2012 Intel Corporation.
+# Copyright(c) 1999 - 2013 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index f045231..3b99719 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index b8020b8..c7bc610 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 124821b..4262b4d 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index 4bd49be..0a08b14 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 9a93223..c25678d 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 0fa4c06..d21f749 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
index 6dc47be..4dae0db 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 4c7e9fe..12784e8 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -7045,7 +7045,7 @@ static int __init e1000_init_module(void)
 	int ret;
 	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
 		e1000e_driver_version);
-	pr_info("Copyright(c) 1999 - 2012 Intel Corporation.\n");
+	pr_info("Copyright(c) 1999 - 2013 Intel Corporation.\n");
 	ret = pci_register_driver(&e1000_driver);
 
 	return ret;
diff --git a/drivers/net/ethernet/intel/e1000e/nvm.c b/drivers/net/ethernet/intel/e1000e/nvm.c
index 1e7882c..84fecc2 100644
--- a/drivers/net/ethernet/intel/e1000e/nvm.c
+++ b/drivers/net/ethernet/intel/e1000e/nvm.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index b29a8a5..19c40d6 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 28b38ff..70f7593 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 32da00c..6b8df65 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2013 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
-- 
1.7.11.7
