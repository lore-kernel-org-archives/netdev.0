From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 7/8] e1000e: update copyright information
Date: Wed, 16 Jun 2010 16:28:11 -0700
Message-ID: <20100616232809.4834.20440.stgit@localhost.localdomain>
References: <20100616232523.4834.84849.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:41452
	"EHLO qmta06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754484Ab0FPX2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 19:28:32 -0400
In-Reply-To: <20100616232523.4834.84849.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
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
index f654db9..a4a0d2b 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 5a6de34..307a72f 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c233496..328b7f4 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 38d79a6..45aebb4 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 312c704..db86850 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index eecb2ec..0cd569a 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 5e55de0..c7292a1 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index a968e3a..df4a279 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f296f6f..77747c7 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -6028,7 +6028,7 @@ static int __init e1000_init_module(void)
 	int ret;
 	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
 		e1000e_driver_version);
-	pr_info("Copyright (c) 1999 - 2009 Intel Corporation.\n");
+	pr_info("Copyright (c) 1999 - 2010 Intel Corporation.\n");
 	ret = pci_register_driver(&e1000_driver);
 
 	return ret;
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index a748460..593251c 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index e471357..3d3dc0c 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,

