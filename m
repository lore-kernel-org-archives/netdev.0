From: Kevin Curtis <Kevin.Curtis@farsite.com>
Subject: [PATCH 001/007] WAN Drivers: Update farsync driver and introduce
 fsflex driver
Date: Wed, 18 Sep 2013 11:11:41 +0100
Message-ID: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA0@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Dermot Smith <dermot.smith@farsite.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Farsite Communications FarSync driver update

Patch 1 of 7

Add new FarSite PCI ID's to the pci_ids.h file


Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>

---

diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/include/linux/pci_ids.h linux-3.10.1_new/include/linux/pci_ids.h
--- linux-3.10.1/include/linux/pci_ids.h	2013-07-13 19:42:41.000000000 +0100
+++ linux-3.10.1_new/include/linux/pci_ids.h	2013-07-26 11:18:39.821065185 +0100
@@ -2284,6 +2284,14 @@
 #define PCI_DEVICE_ID_FARSITE_T4U       0x0640
 #define PCI_DEVICE_ID_FARSITE_TE1       0x1610
 #define PCI_DEVICE_ID_FARSITE_TE1C      0x1612
+#define PCI_DEVICE_ID_FARSITE_DSL_S1    0x2610
+#define PCI_DEVICE_ID_FARSITE_T4E       0x3640
+#define PCI_DEVICE_ID_FARSITE_T4UE      0x4640
+#define PCI_DEVICE_ID_FARSITE_T2UE      0x4620
+#define PCI_DEVICE_ID_FARSITE_T2U_PMC   0x6620
+#define PCI_DEVICE_ID_FARSITE_T2Ee      0x5621
+#define PCI_DEVICE_ID_FARSITE_T4Ee      0x5641
+
 
 #define PCI_VENDOR_ID_ARIMA		0x161f

