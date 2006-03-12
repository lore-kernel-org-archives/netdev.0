From: Mark Brown <broonie@sirena.org.uk>
Subject: [patch 3/4] Add a PCI vendor ID definition for Aculab
Date: Sun, 12 Mar 2006 19:23:02 +0000
Message-ID: <20060312205304.924074000@mercator.sirena.org.uk>
References: <20060312192259.929734000@mercator.sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751800AbWCLVWA@vger.kernel.org>
To: Tim Hockin <thockin@hockin.org>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=pci-vendor-aculab.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a vendor ID definition for Aculab.

Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

Index: e1000-queue/include/linux/pci_ids.h
===================================================================
--- e1000-queue.orig/include/linux/pci_ids.h	2006-02-25 12:50:12.000000000 +0000
+++ e1000-queue/include/linux/pci_ids.h	2006-02-25 12:51:51.000000000 +0000
@@ -1572,6 +1572,8 @@
 #define PCI_VENDOR_ID_NVIDIA_SGS	0x12d2
 #define PCI_DEVICE_ID_NVIDIA_SGS_RIVA128 0x0018
 
+#define PCI_VENDOR_ID_ACULAB 0x12d9
+
 #define PCI_SUBVENDOR_ID_CHASE_PCIFAST		0x12E0
 #define PCI_SUBDEVICE_ID_CHASE_PCIFAST4		0x0031
 #define PCI_SUBDEVICE_ID_CHASE_PCIFAST8		0x0021

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."
