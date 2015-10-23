From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH 1/2] pci_ids: add Netronome Systems vendor
Date: Fri, 23 Oct 2015 19:58:10 +0100
Message-ID: <1445626691-19819-2-git-send-email-jakub.kicinski@netronome.com>
References: <1445626691-19819-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org, rolf.neugebauer@netronome.com,
	jason.mcmullan@netronome.com, simon.horman@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35294 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbbJWS6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 14:58:19 -0400
Received: by wicll6 with SMTP id ll6so43397784wic.0
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 11:58:18 -0700 (PDT)
In-Reply-To: <1445626691-19819-1-git-send-email-jakub.kicinski@netronome.com>
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
