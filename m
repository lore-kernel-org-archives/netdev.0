From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 3/10] Neterion: New driver: pci_ids
Date: 25 Mar 2009 00:12:36 -0800
Message-ID: <1237968756.1655.263.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:43796 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758580AbZCYH1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 03:27:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Update device ID of X3100 Series 10GbE PCIe I/O Virtualized Server Adapter.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp patch_2/include/linux/pci_ids.h patch_3/include/linux/pci_ids.h
--- patch_2/include/linux/pci_ids.h	2009-03-23 09:17:41.000000000 -0700
+++ patch_3/include/linux/pci_ids.h	2009-03-23 09:17:41.000000000 -0700
@@ -2209,6 +2209,8 @@
 #define	PCI_DEVICE_ID_S2IO_UNI		0x5831
 #define PCI_DEVICE_ID_HERC_WIN		0x5732
 #define PCI_DEVICE_ID_HERC_UNI		0x5832
+#define PCI_DEVICE_ID_TITAN_WIN		0x5733
+#define PCI_DEVICE_ID_TITAN_UNI		0x5833
 
 #define PCI_VENDOR_ID_SITECOM		0x182d
 #define PCI_DEVICE_ID_SITECOM_DC105V2	0x3069



