From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/4] igb: Update copyright on all igb driver files.
Date: Mon, 11 Jul 2011 19:15:12 -0700
Message-ID: <1310436914-4017-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1310436914-4017-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17366 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086Ab1GLCPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 22:15:18 -0400
In-Reply-To: <1310436914-4017-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch updates the copyright on the igb driver files to 2011.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/Makefile        |    2 +-
 drivers/net/igb/e1000_82575.c   |    2 +-
 drivers/net/igb/e1000_82575.h   |    2 +-
 drivers/net/igb/e1000_defines.h |    2 +-
 drivers/net/igb/e1000_hw.h      |    2 +-
 drivers/net/igb/e1000_mac.c     |    2 +-
 drivers/net/igb/e1000_mac.h     |    2 +-
 drivers/net/igb/e1000_mbx.c     |    2 +-
 drivers/net/igb/e1000_mbx.h     |    2 +-
 drivers/net/igb/e1000_nvm.c     |    2 +-
 drivers/net/igb/e1000_nvm.h     |    2 +-
 drivers/net/igb/e1000_phy.c     |    2 +-
 drivers/net/igb/e1000_phy.h     |    2 +-
 drivers/net/igb/e1000_regs.h    |    2 +-
 drivers/net/igb/igb.h           |    2 +-
 drivers/net/igb/igb_ethtool.c   |    2 +-
 drivers/net/igb/igb_main.c      |    2 +-
 17 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/igb/Makefile b/drivers/net/igb/Makefile
index 8372cb9..c6e4621 100644
--- a/drivers/net/igb/Makefile
+++ b/drivers/net/igb/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel 82575 PCI-Express Ethernet Linux driver
-# Copyright(c) 1999 - 2009 Intel Corporation.
+# Copyright(c) 1999 - 2011 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 493e331..7b7e157 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index dd6df34..fd28d62 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 6b80d40..446eb5c 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 27153e8..4519a13 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index c822904..2b5ef76 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index 601be99..4927f61 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_mbx.c b/drivers/net/igb/e1000_mbx.c
index 78d48c7..74f2f11 100644
--- a/drivers/net/igb/e1000_mbx.c
+++ b/drivers/net/igb/e1000_mbx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_mbx.h b/drivers/net/igb/e1000_mbx.h
index bb112fb..eddb0f8 100644
--- a/drivers/net/igb/e1000_mbx.h
+++ b/drivers/net/igb/e1000_mbx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index 75bf36a..7dcd65c 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_nvm.h b/drivers/net/igb/e1000_nvm.h
index 7f43564..a2a7ca9 100644
--- a/drivers/net/igb/e1000_nvm.h
+++ b/drivers/net/igb/e1000_nvm.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index d639706..e662554 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_phy.h b/drivers/net/igb/e1000_phy.h
index 2cc1177..8510797 100644
--- a/drivers/net/igb/e1000_phy.h
+++ b/drivers/net/igb/e1000_phy.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 958ca3b..0990f6d 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index f4fa4b1..0389ff6 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 1862c97..ed63ff4 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d6c4bd8..f4d82b2 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2009 Intel Corporation.
+  Copyright(c) 2007-2011 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
-- 
1.7.6

