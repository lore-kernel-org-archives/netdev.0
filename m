From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v3 1/2] pci_ids: add Netronome Systems vendor
Date: Mon, 23 Nov 2015 11:04:56 +0000
Message-ID: <1448276697-2508-2-git-send-email-jakub.kicinski@netronome.com>
References: <20151030.192701.377276134095637949.davem@davemloft.net>
 <1448276697-2508-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38388 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbbKWLFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 06:05:07 -0500
Received: by wmec201 with SMTP id c201so99770175wme.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 03:05:05 -0800 (PST)
In-Reply-To: <1448276697-2508-1-git-send-email-jakub.kicinski@netronome.com>
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
