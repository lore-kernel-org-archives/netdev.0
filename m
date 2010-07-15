From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 4/6] vxge: Update copyright information
Date: Thu, 15 Jul 2010 13:47:26 -0500
Message-ID: <1279219648-10345-4-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51128 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934255Ab0GOSri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 14:47:38 -0400
Received: by mail-pv0-f174.google.com with SMTP id 7so400928pvc.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 11:47:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update copyright information to reflect the Exar purchase of Neterion

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
---
 drivers/net/s2io-regs.h         |    2 +-
 drivers/net/s2io.c              |    4 ++--
 drivers/net/s2io.h              |    2 +-
 drivers/net/vxge/Makefile       |    2 +-
 drivers/net/vxge/vxge-config.c  |    4 ++--
 drivers/net/vxge/vxge-config.h  |    4 ++--
 drivers/net/vxge/vxge-ethtool.c |    4 ++--
 drivers/net/vxge/vxge-ethtool.h |    4 ++--
 drivers/net/vxge/vxge-main.c    |    6 +++---
 drivers/net/vxge/vxge-main.h    |    4 ++--
 drivers/net/vxge/vxge-reg.h     |    4 ++--
 drivers/net/vxge/vxge-traffic.c |    4 ++--
 drivers/net/vxge/vxge-traffic.h |    4 ++--
 drivers/net/vxge/vxge-version.h |    4 ++--
 14 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/s2io-regs.h b/drivers/net/s2io-regs.h
index 416669f..3688325 100644
--- a/drivers/net/s2io-regs.h
+++ b/drivers/net/s2io-regs.h
@@ -1,6 +1,6 @@
 /************************************************************************
  * regs.h: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
- * Copyright(c) 2002-2007 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
 
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index d0af924..f9f9ed8 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1,6 +1,6 @@
 /************************************************************************
  * s2io.c: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
- * Copyright(c) 2002-2007 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  *
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.
@@ -8199,7 +8199,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto register_failed;
 	}
 	s2io_vpd_read(sp);
-	DBG_PRINT(ERR_DBG, "Copyright(c) 2002-2007 Neterion Inc.\n");
+	DBG_PRINT(ERR_DBG, "Copyright(c) 2002-2010 Exar Corp.\n");
 	DBG_PRINT(ERR_DBG, "%s: Neterion %s (rev %d)\n", dev->name,
 		  sp->product_name, pdev->revision);
 	DBG_PRINT(ERR_DBG, "%s: Driver version %s\n", dev->name,
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 5e52c75..3645fb3 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -1,6 +1,6 @@
 /************************************************************************
  * s2io.h: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
- * Copyright(c) 2002-2007 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
 
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.
diff --git a/drivers/net/vxge/Makefile b/drivers/net/vxge/Makefile
index 8992ca2..b625e2c 100644
--- a/drivers/net/vxge/Makefile
+++ b/drivers/net/vxge/Makefile
@@ -1,5 +1,5 @@
 #
-# Makefile for Neterion Inc's X3100 Series 10 GbE PCIe # I/O
+# Makefile for Exar Corp's X3100 Series 10 GbE PCIe I/O
 # Virtualized Server Adapter linux driver
 
 obj-$(CONFIG_VXGE) += vxge.o
diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 297f0d2..0e6db59 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -7,9 +7,9 @@
  * system is licensed under the GPL.
  * See the file COPYING in this distribution for more information.
  *
- * vxge-config.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ * vxge-config.c: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O
  *                Virtualized Server Adapter.
- * Copyright(c) 2002-2009 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #include <linux/vmalloc.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 4ae2625..1a94343 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -7,9 +7,9 @@
  * system is licensed under the GPL.
  * See the file COPYING in this distribution for more information.
  *
- * vxge-config.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ * vxge-config.h: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O
  *                Virtualized Server Adapter.
- * Copyright(c) 2002-2009 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #ifndef VXGE_CONFIG_H
 #define VXGE_CONFIG_H
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
index cadef85..05679e3 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -7,9 +7,9 @@
  * system is licensed under the GPL.
  * See the file COPYING in this distribution for more information.
  *
- * vxge-ethtool.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ * vxge-ethtool.c: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O
  *                 Virtualized Server Adapter.
- * Copyright(c) 2002-2009 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #include<linux/ethtool.h>
 #include <linux/slab.h>
diff --git a/drivers/net/vxge/vxge-ethtool.h b/drivers/net/vxge/vxge-ethtool.h
index 1c3df0a..6cf3044 100644
--- a/drivers/net/vxge/vxge-ethtool.h
+++ b/drivers/net/vxge/vxge-ethtool.h
@@ -7,9 +7,9 @@
  * system is licensed under the GPL.
  * See the file COPYING in this distribution for more information.
  *
- * vxge-ethtool.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ * vxge-ethtool.h: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O
  *                 Virtualized Server Adapter.
- * Copyright(c) 2002-2009 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #ifndef _VXGE_ETHTOOL_H
 #define _VXGE_ETHTOOL_H
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 48f1732..94d87e8 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -7,9 +7,9 @@
 * system is licensed under the GPL.
 * See the file COPYING in this distribution for more information.
 *
-* vxge-main.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+* vxge-main.c: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O
 *              Virtualized Server Adapter.
-* Copyright(c) 2002-2009 Neterion Inc.
+* Copyright(c) 2002-2010 Exar Corp.
 *
 * The module loadable parameters that are supported by the driver and a brief
 * explanation of all the variables:
@@ -4433,7 +4433,7 @@ vxge_starter(void)
 	char version[32];
 	snprintf(version, 32, "%s", DRV_VERSION);
 
-	printk(KERN_INFO "%s: Copyright(c) 2002-2009 Neterion Inc\n",
+	printk(KERN_INFO "%s: Copyright(c) 2002-2010 Exar Corp.\n",
 		VXGE_DRIVER_NAME);
 	printk(KERN_INFO "%s: Driver version: %s\n",
 			VXGE_DRIVER_NAME, version);
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 5982396..2e3b064 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -7,9 +7,9 @@
  * system is licensed under the GPL.
  * See the file COPYING in this distribution for more information.
  *
- * vxge-main.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ * vxge-main.h: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O
  *              Virtualized Server Adapter.
- * Copyright(c) 2002-2009 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #ifndef VXGE_MAIN_H
 #define VXGE_MAIN_H
diff --git a/drivers/net/vxge/vxge-reg.h b/drivers/net/vxge/vxge-reg.h
index 9a0cf8e..3dd5c96 100644
--- a/drivers/net/vxge/vxge-reg.h
+++ b/drivers/net/vxge/vxge-reg.h
@@ -7,9 +7,9 @@
  * system is licensed under the GPL.
  * See the file COPYING in this distribution for more information.
  *
- * vxge-reg.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O Virtualized
+ * vxge-reg.h: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O Virtualized
  *             Server Adapter.
- * Copyright(c) 2002-2009 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #ifndef VXGE_REG_H
 #define VXGE_REG_H
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 1a70783..cedf08f 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -7,9 +7,9 @@
  * system is licensed under the GPL.
  * See the file COPYING in this distribution for more information.
  *
- * vxge-traffic.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ * vxge-traffic.c: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O
  *                 Virtualized Server Adapter.
- * Copyright(c) 2002-2009 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #include <linux/etherdevice.h>
 
diff --git a/drivers/net/vxge/vxge-traffic.h b/drivers/net/vxge/vxge-traffic.h
index c252f3d..6fa07d1 100644
--- a/drivers/net/vxge/vxge-traffic.h
+++ b/drivers/net/vxge/vxge-traffic.h
@@ -7,9 +7,9 @@
  * system is licensed under the GPL.
  * See the file COPYING in this distribution for more information.
  *
- * vxge-traffic.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ * vxge-traffic.h: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O
  *                 Virtualized Server Adapter.
- * Copyright(c) 2002-2009 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #ifndef VXGE_TRAFFIC_H
 #define VXGE_TRAFFIC_H
diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index 5da7ab1..4008e6b 100644
--- a/drivers/net/vxge/vxge-version.h
+++ b/drivers/net/vxge/vxge-version.h
@@ -7,9 +7,9 @@
  * system is licensed under the GPL.
  * See the file COPYING in this distribution for more information.
  *
- * vxge-version.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ * vxge-version.h: Driver for Exar Corp's X3100 Series 10GbE PCIe I/O
  *                 Virtualized Server Adapter.
- * Copyright(c) 2002-2009 Neterion Inc.
+ * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #ifndef VXGE_VERSION_H
 
-- 
1.7.0.4

