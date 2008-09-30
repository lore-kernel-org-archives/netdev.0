From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: add sub vendor/device ids.
Date: Tue, 30 Sep 2008 09:05:48 -0700
Message-ID: <1222790748-31209-1-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [69.105.43.10] ([69.105.43.10]:53525 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751213AbYI3Qgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 12:36:53 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 include/linux/pci_ids.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index a65b082..6954096 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2256,6 +2256,11 @@
 #define PCI_DEVICE_ID_NX2031_XG_MGMT	0x0024
 #define PCI_DEVICE_ID_NX2031_XG_MGMT2	0x0025
 #define PCI_DEVICE_ID_NX3031		0x0100
+#define PCI_SUBVENDOR_ID_HP			0x103c
+#define PCI_SUBDEVICE_ID_HP_NC522M		0x171b
+#define PCI_SUBDEVICE_ID_HP_NC375I_NC524SFP	0x3251
+#define PCI_SUBDEVICE_ID_HP_NC375I		0x705a
+#define PCI_SUBDEVICE_ID_HP_NC522SFP		0x705b
 
 #define PCI_VENDOR_ID_AKS		0x416c
 #define PCI_DEVICE_ID_AKS_ALADDINCARD	0x0100
-- 
1.5.4.3

