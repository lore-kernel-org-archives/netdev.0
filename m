From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 13/23] e1000e: update copyright information
Date: Sat, 21 Nov 2009 01:25:45 -0800
Message-ID: <20091121092544.5715.92494.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:37553
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752516AbZKUJZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:25:57 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |    2 +-
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
 11 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 6fe1b3c..a984bc3 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 1190167..86d2809 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 602598c..5ac8675 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index d024e20..103dc64 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index fd79214..b6243ca 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 842d8e7..426155c 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index dd94fc2..191a4e3 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index f664fc0..0c6ad0e 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 6eb9693..a571676 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -5364,7 +5364,7 @@ static int __init e1000_init_module(void)
 	int ret;
 	printk(KERN_INFO "%s: Intel(R) PRO/1000 Network Driver - %s\n",
 	       e1000e_driver_name, e1000e_driver_version);
-	printk(KERN_INFO "%s: Copyright (c) 1999-2008 Intel Corporation.\n",
+	printk(KERN_INFO "%s: Copyright (c) 1999 - 2009 Intel Corporation.\n",
 	       e1000e_driver_name);
 	ret = pci_register_driver(&e1000_driver);
 	pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY, e1000e_driver_name,
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 1342e0b..2e39977 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 765dc38..440f366 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2008 Intel Corporation.
+  Copyright(c) 1999 - 2009 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,

