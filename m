From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 09/10] e1000: Version bump, contact fix, year string change
Date: Fri, 14 Apr 2006 11:37:08 -0700
Message-ID: <20060414183707.3461.1236.stgit@gitlost.site>
References: <20060414183423.3461.32772.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:58372 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751406AbWDNSda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:33:30 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060414183423.3461.32772.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add the sourceforge project mailinglist to the contact information.

Bump version to 7.0.38-k2

Update copyright string with the new year.


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/e1000/Makefile        |    1 +
 drivers/net/e1000/e1000.h         |    3 ++-
 drivers/net/e1000/e1000_ethtool.c |    3 ++-
 drivers/net/e1000/e1000_hw.c      |    3 ++-
 drivers/net/e1000/e1000_hw.h      |    3 ++-
 drivers/net/e1000/e1000_main.c    |    7 ++++---
 drivers/net/e1000/e1000_osdep.h   |    3 ++-
 drivers/net/e1000/e1000_param.c   |    3 ++-
 8 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000/Makefile b/drivers/net/e1000/Makefile
index ca9f895..92823ac 100644
--- a/drivers/net/e1000/Makefile
+++ b/drivers/net/e1000/Makefile
@@ -22,6 +22,7 @@
 # 
 # Contact Information:
 # Linux NICS <linux.nics@intel.com>
+# e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
 # Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 #
 ################################################################################
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 2dfabdb..2bc34fb 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -22,6 +22,7 @@
   
   Contact Information:
   Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 *******************************************************************************/
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index ecccca3..e48dc57 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -22,6 +22,7 @@
   
   Contact Information:
   Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 *******************************************************************************/
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 523c2c9..4c796e5 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -22,6 +22,7 @@
   
   Contact Information:
   Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 *******************************************************************************/
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 150e45e..03d07eb 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -22,6 +22,7 @@
   
   Contact Information:
   Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 *******************************************************************************/
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 3c37c40..82d443b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -22,6 +22,7 @@
   
   Contact Information:
   Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 *******************************************************************************/
@@ -74,9 +75,9 @@ static char e1000_driver_string[] = "Int
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION "7.0.33-k2"DRIVERNAPI
+#define DRV_VERSION "7.0.38-k2"DRIVERNAPI
 char e1000_driver_version[] = DRV_VERSION;
-static char e1000_copyright[] = "Copyright (c) 1999-2005 Intel Corporation.";
+static char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
  *
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 9790db9..048d052 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -22,6 +22,7 @@
   
   Contact Information:
   Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 *******************************************************************************/
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index e0a4d37..e55f896 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -22,6 +22,7 @@
   
   Contact Information:
   Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 *******************************************************************************/



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
