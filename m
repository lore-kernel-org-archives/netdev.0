From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: [PATCH 2.6.33 4/4] net: Add PCI vendor and device ids for Micrel KSZ8841/2 PCI devices
Date: Fri, 29 Jan 2010 14:45:49 -0800
Message-ID: <14385191E87B904DBD836449AA30269D021A50@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Alan Cox" <alan@lxorguk.ukuu.org.uk>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756041Ab0A2Wp5@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@micrel.com>

Add PCI vendor and device ids for Micrel KSZ8841/2 PCI devices.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
---
This is a resubmission of the Micrel KSZ8841/2 PCI Ethernet driver.

--- linux-2.6.33-rc5.old/include/linux/pci_ids.h	2010-01-21 15:31:35.000000000 -0800
+++ linux-2.6.33-rc5.new/include/linux/pci_ids.h	2010-01-29 10:38:53.000000000 -0800
@@ -2199,6 +2199,12 @@
 #define PCI_VENDOR_ID_NETCELL		0x169c
 #define PCI_DEVICE_ID_REVOLUTION	0x0044
 
+#define PCI_VENDOR_ID_MICREL_KS		0x16c6
+#define PCI_DEVICE_ID_MICREL_KS8692	0x8692
+#define PCI_DEVICE_ID_MICREL_KS8695	0x8695
+#define PCI_DEVICE_ID_MICREL_KS8841	0x8841
+#define PCI_DEVICE_ID_MICREL_KS8842	0x8842
+
 #define PCI_VENDOR_ID_CENATEK		0x16CA
 #define PCI_DEVICE_ID_CENATEK_IDE	0x0001
 
