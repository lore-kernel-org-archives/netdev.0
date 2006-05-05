From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [PATCH 2/3] bcm43xx-d80211: fix whitespace
Date: Fri, 5 May 2006 21:59:59 +0200
Message-ID: <20060505215959.35be978d@localhost>
References: <20060505215542.25d310dd@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.polimi.it ([131.175.12.3]:9446 "EHLO polimi.it")
	by vger.kernel.org with ESMTP id S1751763AbWEEUAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 16:00:38 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060505215542.25d310dd@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix whitespace.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 00:50:00.370034536 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 02:43:44.981535888 +0200
@@ -128,13 +128,13 @@
 	static struct pci_device_id bcm43xx_pci_tbl[] = {
 	/* Broadcom 4303 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-		/* Broadcom 4307 802.11b */
+	/* Broadcom 4307 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-		/* Broadcom 4318 802.11b/g */
+	/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4306 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-		/* Broadcom 4306 802.11a */
+	/* Broadcom 4306 802.11a */
 //	{ PCI_VENDOR_ID_BROADCOM, 0x4321, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4309 802.11a/b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4324, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },


--
Ciao
Stefano
