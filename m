From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 9/9] ixgb: update version, dates
Date: Fri, 26 May 2006 09:52:14 -0700
Message-ID: <20060526165213.30514.97188.stgit@gitlost.site>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:36870 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751135AbWEZQrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:47:10 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


increase the year dates to 2006 and bump the version to 1.0.109-k2

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/Makefile       |    2 +-
 drivers/net/ixgb/ixgb.h         |    2 +-
 drivers/net/ixgb/ixgb_ee.c      |    2 +-
 drivers/net/ixgb/ixgb_ee.h      |    2 +-
 drivers/net/ixgb/ixgb_ethtool.c |    2 +-
 drivers/net/ixgb/ixgb_hw.c      |    2 +-
 drivers/net/ixgb/ixgb_hw.h      |    2 +-
 drivers/net/ixgb/ixgb_ids.h     |    2 +-
 drivers/net/ixgb/ixgb_main.c    |    6 +++---
 drivers/net/ixgb/ixgb_osdep.h   |    2 +-
 drivers/net/ixgb/ixgb_param.c   |    2 +-
 11 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgb/Makefile b/drivers/net/ixgb/Makefile
index 7c7aff1..a8a2d3d 100644
--- a/drivers/net/ixgb/Makefile
+++ b/drivers/net/ixgb/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # 
-# Copyright(c) 1999 - 2002 Intel Corporation. All rights reserved.
+# Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
 # 
 # This program is free software; you can redistribute it and/or modify it 
 # under the terms of the GNU General Public License as published by the Free 
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index bdbaf5a..a83ef28 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 661a46b..8357c55 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ixgb/ixgb_ee.h
index 5190aa8..bf6fa22 100644
--- a/drivers/net/ixgb/ixgb_ee.h
+++ b/drivers/net/ixgb/ixgb_ee.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 949f69d..cf19b89 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 620cad4..f7fa10e 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index 19513c6..cb45689 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
index e119c05..40a085f 100644
--- a/drivers/net/ixgb/ixgb_ids.h
+++ b/drivers/net/ixgb/ixgb_ids.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index aecdc00..57006fb 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -36,9 +36,9 @@ static char ixgb_driver_string[] = "Inte
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION		"1.0.104-k4"DRIVERNAPI
+#define DRV_VERSION		"1.0.109-k2"DRIVERNAPI
 char ixgb_driver_version[] = DRV_VERSION;
-static char ixgb_copyright[] = "Copyright (c) 1999-2005 Intel Corporation.";
+static char ixgb_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
  *
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
index dba2048..ee982fe 100644
--- a/drivers/net/ixgb/ixgb_osdep.h
+++ b/drivers/net/ixgb/ixgb_osdep.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 388462c..39fbed2 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 



--
Auke Kok <auke-jan.h.kok@intel.com>
