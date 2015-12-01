From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v5 1/2] pci_ids: add Netronome Systems vendor
Date: Tue,  1 Dec 2015 14:55:21 +0000
Message-ID: <1448981722-14022-2-git-send-email-jakub.kicinski@netronome.com>
References: <1445969758-12779-1-git-send-email-jakub.kicinski@netronome.com>
 <1448981722-14022-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34570 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756543AbbLAOz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 09:55:29 -0500
Received: by wmvv187 with SMTP id v187so210649492wmv.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 06:55:28 -0800 (PST)
In-Reply-To: <1448981722-14022-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PCI vendor id for Netronome Systems.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>
---
 include/linux/pci_ids.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index d9ba49cedc5d..1acbefc4bbda 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2495,6 +2495,8 @@
 #define PCI_DEVICE_ID_KORENIX_JETCARDF2	0x1700
 #define PCI_DEVICE_ID_KORENIX_JETCARDF3	0x17ff
 
+#define PCI_VENDOR_ID_NETRONOME		0x19ee
+
 #define PCI_VENDOR_ID_QMI		0x1a32
 
 #define PCI_VENDOR_ID_AZWAVE		0x1a3b
-- 
1.9.1
